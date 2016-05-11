Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAC26B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 07:16:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so39156663wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 04:16:09 -0700 (PDT)
Received: from 8.mo2.mail-out.ovh.net (8.mo2.mail-out.ovh.net. [188.165.52.147])
        by mx.google.com with ESMTPS id h201si37996857wme.86.2016.05.11.04.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 04:16:07 -0700 (PDT)
Received: from player771.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo2.mail-out.ovh.net (Postfix) with ESMTP id 60AD610009F2
	for <linux-mm@kvack.org>; Wed, 11 May 2016 13:16:07 +0200 (CEST)
Subject: Re: [Question] Missing data after DMA read transfer - mm issue with
 transparent huge page?
References: <15edf085-c21b-aa1c-9f1f-057d17b8a1a3@morey-chaisemartin.com>
 <alpine.LSU.2.11.1605022020560.5004@eggly.anvils>
 <20160503101153.GA7241@gmail.com>
 <07619be9-e812-5459-26dd-ceb8c6490520@morey-chaisemartin.com>
 <20160510100104.GA18820@gmail.com>
From: Nicolas Morey Chaisemartin <devel@morey-chaisemartin.com>
Message-ID: <60fc4f9f-fc8e-84a4-da84-a3c823b9b5bb@morey-chaisemartin.com>
Date: Wed, 11 May 2016 13:15:54 +0200
MIME-Version: 1.0
In-Reply-To: <20160510100104.GA18820@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Williamson <alex.williamson@redhat.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



Le 05/10/2016 a 12:01 PM, Jerome Glisse a ecrit :
> On Tue, May 10, 2016 at 09:04:36AM +0200, Nicolas Morey Chaisemartin wrote:
>> Le 05/03/2016 a 12:11 PM, Jerome Glisse a ecrit :
>>> On Mon, May 02, 2016 at 09:04:02PM -0700, Hugh Dickins wrote:
>>>> On Fri, 29 Apr 2016, Nicolas Morey Chaisemartin wrote:
[...]
>> Hi,
>>
>> I backported the patch to 3.10 (had to copy paste pmd_protnone defitinition from 4.5) and it's working !
>> I'll open a ticket in Redhat tracker to try and get this fixed in RHEL7.
>>
>> I have a dumb question though: how can we end up in numa/misplaced memory code on a single socket system?
>>
> This patch is not a fix, do you see bug message in kernel log ? Because if
> you do that it means we have a bigger issue.
>
> You did not answer one of my previous question, do you set get_user_pages
> with write = 1 as a paremeter ?
>
> Also it would be a lot easier if you were testing with lastest 4.6 or 4.5
> not RHEL kernel as they are far appart and what might looks like same issue
> on both might be totaly different bugs.
>
> If you only really care about RHEL kernel then open a bug with Red Hat and
> you can add me in bug-cc <jglisse@redhat.com>
>
> Cheers,
> Jerome

I finally managed to get a proper setup.
I build a vanilla 4.5 kernel from git tree using the Centos7 config, my test fails as usual.
I applied your patch, rebuild => still fails and no new messages in dmesg.

Now that I don't have to go through the RPM repackaging, I can try out things much quicker if you have any ideas.

Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
