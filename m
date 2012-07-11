Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 918136B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 02:39:52 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm/slob: avoid type warning about alignment value
Date: Wed, 11 Jul 2012 06:39:43 +0000
References: <201207102055.35278.arnd@arndb.de> <alpine.DEB.2.00.1207101815580.684@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1207101815580.684@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201207110639.43587.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wednesday 11 July 2012, David Rientjes wrote:
> Wouldn't it be better to avoid this problem more generally by casting the 
> __alignof__ for ARCH_{KMALLOC,SLAB}_MINALIGN to int in slab.h?  All 
> architectures that define these themselves will be using plain integers, 
> the problem is __alignof__ returning size_t when undefined.

I thought about it but I wasn't sure if that would cover all possible
cases. My version at least is known not to introduce a different type
mismatch on another architecture.

Also, size_t seems to be the correct type here, while the untyped
definition is just an int.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
