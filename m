Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2528D6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 10:51:53 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id u23so95074587vkb.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:51:53 -0700 (PDT)
Received: from mail-qg0-x242.google.com (mail-qg0-x242.google.com. [2607:f8b0:400d:c04::242])
        by mx.google.com with ESMTPS id 62si5405426qke.71.2016.05.11.07.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 07:51:52 -0700 (PDT)
Received: by mail-qg0-x242.google.com with SMTP id 90so3112144qgz.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:51:52 -0700 (PDT)
Date: Wed, 11 May 2016 16:51:41 +0200
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
Message-ID: <20160511145141.GA5288@gmail.com>
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
 <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
 <20160510100104.GA18820@gmail.com>
 <60fc4f9f-fc8e-84a4-da84-a3c823b9b5bb@morey-chaisemartin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <60fc4f9f-fc8e-84a4-da84-a3c823b9b5bb@morey-chaisemartin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Morey Chaisemartin <devel@morey-chaisemartin.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 11, 2016 at 01:15:54PM +0200, Nicolas Morey Chaisemartin wrote:
> 
> 
> Le 05/10/2016 a 12:01 PM, Jerome Glisse a ecrit :
> > On Tue, May 10, 2016 at 09:04:36AM +0200, Nicolas Morey Chaisemartin wrote:
> >> Le 05/03/2016 a 12:11 PM, Jerome Glisse a ecrit :
> >>> On Mon, May 02, 2016 at 09:04:02PM -0700, Hugh Dickins wrote:
> >>>> On Fri, 29 Apr 2016, Nicolas Morey Chaisemartin wrote:
> [...]
> >> Hi,
> >>
> >> I backported the patch to 3.10 (had to copy paste pmd_protnone defitinition from 4.5) and it's working !
> >> I'll open a ticket in Redhat tracker to try and get this fixed in RHEL7.
> >>
> >> I have a dumb question though: how can we end up in numa/misplaced memory code on a single socket system?
> >>
> > This patch is not a fix, do you see bug message in kernel log ? Because if
> > you do that it means we have a bigger issue.
> >
> > You did not answer one of my previous question, do you set get_user_pages
> > with write = 1 as a paremeter ?
> >
> > Also it would be a lot easier if you were testing with lastest 4.6 or 4.5
> > not RHEL kernel as they are far appart and what might looks like same issue
> > on both might be totaly different bugs.
> >
> > If you only really care about RHEL kernel then open a bug with Red Hat and
> > you can add me in bug-cc <jglisse@redhat.com>
> >
> > Cheers,
> > Jerome
> 
> I finally managed to get a proper setup.
> I build a vanilla 4.5 kernel from git tree using the Centos7 config, my test fails as usual.
> I applied your patch, rebuild => still fails and no new messages in dmesg.
> 
> Now that I don't have to go through the RPM repackaging, I can try out things much quicker if you have any ideas.
> 

Still an issue if you boot with transparent_hugepage=never ?

Also to simplify investigation force write to 1 all the time no matter what.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
