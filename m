Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 059296B00E7
	for <linux-mm@kvack.org>; Sat, 21 Apr 2012 14:26:46 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so10213486vbb.14
        for <linux-mm@kvack.org>; Sat, 21 Apr 2012 11:26:46 -0700 (PDT)
Message-ID: <4F92FBE3.50709@garzik.org>
Date: Sat, 21 Apr 2012 14:26:43 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
References: <1334863211-19504-1-git-send-email-tytso@mit.edu> <4F912880.70708@panasas.com> <alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com> <1334919662.5879.23.camel@dabdike>
In-Reply-To: <1334919662.5879.23.camel@dabdike>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Lukas Czerner <lczerner@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On 04/20/2012 07:01 AM, James Bottomley wrote:
> The concern I have is that the notion of hot and cold files *isn't*
> propagated to the page cache, it's just shared between the fs and the
> disk.

Bingo -- full-file hint is too coarse-grained for some workloads.  Page 
granularity would propagate to the VM as well as block layer, and give 
the required flexibility to all workloads.  As well as covering the 
full-file case.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
