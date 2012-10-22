Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 000FE6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:42:41 -0400 (EDT)
Message-ID: <508506FB.3050604@parallels.com>
Date: Mon, 22 Oct 2012 12:42:35 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [14/15] stat: Use size_t for sizes instead of unsigned
References: <20121019142254.724806786@linux.com> <0000013a797066fe-be951901-f108-4705-95bb-e0d6a2b2af85-000000@email.amazonses.com>
In-Reply-To: <0000013a797066fe-be951901-f108-4705-95bb-e0d6a2b2af85-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:32 PM, Christoph Lameter wrote:
> On some platforms (such as IA64) the large page size may results in
> slab allocations to be allowed of numbers that do not fit in 32 bit.
> 

> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
