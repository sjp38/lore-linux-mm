Date: Mon, 22 Dec 2003 23:30:14 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-mm1
Message-ID: <106620000.1072164613@[10.10.2.4]>
In-Reply-To: <20031222211131.70a963fb.akpm@osdl.org>
References: <20031222211131.70a963fb.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

These look new to me.

In file included from init/initramfs.c:393:
init/../lib/inflate.c: In function `gunzip':
init/../lib/inflate.c:1123: warning: value computed is not used
init/../lib/inflate.c:1124: warning: value computed is not used
init/../lib/inflate.c:1125: warning: value computed is not used
init/../lib/inflate.c:1126: warning: value computed is not used
In file included from arch/i386/boot/compressed/misc.c:129:
arch/i386/boot/compressed/../../../../lib/inflate.c: In function `gunzip':
arch/i386/boot/compressed/../../../../lib/inflate.c:1123: warning: value computed is not used
arch/i386/boot/compressed/../../../../lib/inflate.c:1124: warning: value computed is not used
arch/i386/boot/compressed/../../../../lib/inflate.c:1125: warning: value computed is not used
arch/i386/boot/compressed/../../../../lib/inflate.c:1126: warning: value computed is not used


M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
