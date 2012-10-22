Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D8FA96B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 04:33:01 -0400 (EDT)
Message-ID: <508504B6.70800@parallels.com>
Date: Mon, 22 Oct 2012 12:32:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK2 [09/15] slab: Common name for the per node structures
References: <20121019142254.724806786@linux.com> <0000013a79802816-21b3fa95-f2af-4fa0-8f06-2ba25de20443-000000@email.amazonses.com>
In-Reply-To: <0000013a79802816-21b3fa95-f2af-4fa0-8f06-2ba25de20443-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On 10/19/2012 06:49 PM, Christoph Lameter wrote:
> Rename the structure used for the per node structures in slab
> to have a name that expresses that fact.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 

Trivial name change, already discussed in the last submission.

Acked-by: Glauber Costa <glommer@parallels.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
