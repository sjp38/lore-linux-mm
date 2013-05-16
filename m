Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 362616B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 09:33:25 -0400 (EDT)
Message-ID: <5194E021.8080906@tilera.com>
Date: Thu, 16 May 2013 09:33:21 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/10] tile: uaccess s/might_sleep/might_fault/
References: <cover.1368702323.git.mst@redhat.com> <018bba1e097552bc4054e6d90e3f03e7c9a632bb.1368702323.git.mst@redhat.com>
In-Reply-To: <018bba1e097552bc4054e6d90e3f03e7c9a632bb.1368702323.git.mst@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On 5/16/2013 7:15 AM, Michael S. Tsirkin wrote:
> The only reason uaccess routines might sleep
> is if they fault. Make this explicit.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  arch/tile/include/asm/uaccess.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
