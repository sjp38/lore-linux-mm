Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 0284F6B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:10:41 -0400 (EDT)
Message-ID: <516807CB.6040208@parallels.com>
Date: Fri, 12 Apr 2013 17:10:35 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] pagemap: Introduce the /proc/PID/pagemap2 file
References: <51669E5F.4000801@parallels.com> <51669EA5.20209@parallels.com> <20130411141944.dc17b3b1c78132eedec06aa6@linux-foundation.org>
In-Reply-To: <20130411141944.dc17b3b1c78132eedec06aa6@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 04/12/2013 01:19 AM, Andrew Morton wrote:
> On Thu, 11 Apr 2013 15:29:41 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> This file is the same as the pagemap one, but shows entries with bits
>> 55-60 being zero (reserved for future use). Next patch will occupy one
>> of them.
> 
> I'm not understanding the motivation for this.  What does the current
> /proc/pid/pagemap have in those bit positions?

A constant PAGE_SHIFT value.

> 
> .
> 

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
