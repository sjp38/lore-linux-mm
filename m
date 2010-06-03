Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 372C76B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:53:52 -0400 (EDT)
Received: by pwj5 with SMTP id 5so353063pwj.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 19:53:50 -0700 (PDT)
Message-ID: <4C07179F.5080106@vflare.org>
Date: Thu, 03 Jun 2010 08:16:55 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
References: <20100528173510.GA12166@ca-server1.us.oracle.comAANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com> <1d88619a-bb1e-493f-ad96-bf204b60938d@default 20100602163827.GA5450@barrios-desktop> <489aa002-6d42-4dd5-bb66-81c665f8cdd1@default>
In-Reply-To: <489aa002-6d42-4dd5-bb66-81c665f8cdd1@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On 06/03/2010 04:32 AM, Dan Magenheimer wrote:
>> From: Minchan Kim [mailto:minchan.kim@gmail.com]
> 
>>> I am also eagerly awaiting Nitin Gupta's cleancache backend
>>> and implementation to do in-kernel page cache compression.
>>
>> Do Nitin say he will make backend of cleancache for
>> page cache compression?
>>
>> It would be good feature.
>> I have a interest, too. :)
> 
> That was Nitin's plan for his GSOC project when we last discussed
> this.  Nitin is on the cc list and can comment if this has
> changed.
> 


Yes, I have just started work on in-kernel page cache compression
backend for cleancache :)

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
