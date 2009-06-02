Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 82F536B00C0
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:27:17 -0400 (EDT)
Message-ID: <4A24EF80.5070606@redhat.com>
Date: Tue, 02 Jun 2009 12:23:12 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com> <20090601123503.2337a79b.akpm@linux-foundation.org> <4A242F94.9010704@redhat.com> <20090602091544.GC15756@elf.ucw.cz>
In-Reply-To: <20090602091544.GC15756@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, linux-mm@kvack.org, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> Ouch and please... don't stop useful printk() warnings just because
> some 'pie-in-the-sky future binary protocol'. That's what happened in
> ACPI land with battery critical, and it is also why I don't get
> battery warnings on some of my machines.
>   

btw, adding a printk() for acpi battery state may have helped you and 
other kernel developers, but would have done nothing for ordinary humans 
using Linux on their laptops.  We should cater to the general population 
first and treat developer needs as nice-to-haves.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
