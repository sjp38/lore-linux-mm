Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 362056B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 13:25:56 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id ik5so7530463vcb.21
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:25:55 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id mb10si21808425vcb.59.2014.07.09.10.25.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 10:25:55 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id lf12so7616258vcb.32
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:25:54 -0700 (PDT)
Date: Wed, 9 Jul 2014 13:26:10 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: mm: Various preparatory patches for hmm and kfd
Message-ID: <20140709172609.GD4249@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <20140709164637.GR1958@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140709164637.GR1958@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 09, 2014 at 06:46:37PM +0200, Joerg Roedel wrote:
> On Tue, Jul 08, 2014 at 05:59:57PM -0400, j.glisse@gmail.com wrote:
> > Hope this address any previous concern about those patches.
> 
> Okay, so as you may have read out of my previous comments my main
> concern is that I don't know the details why all of this is needed for
> HMM. Do you have any high-level overview of the devices HMM is aimed for
> and the design of HMM?
> 
> Maybe you have already posted this somewhere and I missed it, so any
> link to archives or explanation would be good to understand your
> use-cases better.
> 
> 

Lengthy description :

http://comments.gmane.org/gmane.linux.kernel.mm/116584

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
