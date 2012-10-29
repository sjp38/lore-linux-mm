Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 9FA896B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:32:19 -0400 (EDT)
Message-ID: <508E855C.3050802@parallels.com>
Date: Mon, 29 Oct 2012 17:32:12 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK4 [12/15] Common definition for the array of kmalloc caches
References: <20121024150518.156629201@linux.com> <0000013a934f6baa-f14783e0-6087-4096-af87-ed20597ef21b-000000@email.amazonses.com>
In-Reply-To: <0000013a934f6baa-f14783e0-6087-4096-af87-ed20597ef21b-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/24/2012 07:06 PM, Christoph Lameter wrote:
> Have a common definition fo the kmalloc cache arrays in
> SLAB and SLUB
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Makes sense:
Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
