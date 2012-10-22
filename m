Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id AC9126B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 05:51:14 -0400 (EDT)
Message-ID: <5085170B.3080007@parallels.com>
Date: Mon, 22 Oct 2012 13:51:07 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [13/15] Common function to create the kmalloc array
References: <20121019142254.724806786@linux.com> <0000013a7979e98c-f67c87ff-e040-4002-a682-95e35dcd7005-000000@email.amazonses.com>
In-Reply-To: <0000013a7979e98c-f67c87ff-e040-4002-a682-95e35dcd7005-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:42 PM, Christoph Lameter wrote:
> The kmalloc array is created in similar ways in both SLAB
> and SLUB. Create a common function and have both allocators
> call that function.
> 
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Checkpatch screams about two space-ident errors in this patch.
Please fix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
