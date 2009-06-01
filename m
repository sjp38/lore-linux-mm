Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 822C45F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:33:28 -0400 (EDT)
Message-ID: <4A23FF89.2060603@redhat.com>
Date: Mon, 01 Jun 2009 19:19:21 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Subject: Warn if we run out of swap space
>
> Running out of swap space means that the evicton of anonymous pages may no longer
> be possible which can lead to OOM conditions.
>
> Print a warning when swap space first becomes exhausted.
>   

We really should have a machine readable channel for this sort of 
information, so it can be plumbed to a userspace notification bubble the 
user can ignore.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
