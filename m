Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B35B46B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:48:13 -0400 (EDT)
Message-ID: <49C903B5.8020504@wpkg.org>
Date: Tue, 24 Mar 2009 17:00:53 +0100
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
Subject: Re: why my systems never cache more than ~900 MB?
References: <49C89CE0.2090103@wpkg.org> <200903250220.45575.nickpiggin@yahoo.com.au> <49C8FDD4.7070900@wpkg.org> <alpine.DEB.1.10.0903241142510.13587@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0903241142510.13587@qirst.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter schrieb:
> On Tue, 24 Mar 2009, Tomasz Chmielewski wrote:
> 
>> Nick Piggin schrieb:
>> Does not help me, as what interests me here on these machines is mainly
>> caching block device data; they are iSCSI targets and access block devices
>> directly.
> 
> You can run a 64 bit kernel on those machines. 64 bit kernels can use
> 32 bit userspace without a problem. Just install an additional kernel and
> try booting your existing setup with it.
> 
>> What split should I choose to enable blockdev mapping on the whole memory on
>> 32 bit system with 3 or 4 GB RAM? Is it possible with 4 GB RAM at all?
> 
> A 64 bit kernel will do the trick.

This hardware has problems booting 64 bit kernels (read: CPUs come from 
the 32-bit land).


-- 
Tomasz Chmielewski
http://wpkg.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
