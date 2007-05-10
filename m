Date: Thu, 10 May 2007 01:36:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Request-For-Test] [PATCH] change zonelist order v6 [0/3]
 Introduction
Message-Id: <20070510013619.7b8c2457.akpm@linux-foundation.org>
In-Reply-To: <20070510161611.fe1a696b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070510161611.fe1a696b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Lee.Schermerhorn@hp.com, apw@shadowen.org, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 16:16:11 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This is zonelist-order-fix patch version 6. against 2.6.21-mm2.

This is new:

WARNING: mm/built-in.o - Section mismatch: reference to .init.text: from .text between '__build_all_zonelists' (at offset 0x3d13) and 'build_all_zonelists'
WARNING: mm/built-in.o - Section mismatch: reference to .init.text: from .text between '__build_all_zonelists' (at offset 0x3d2c) and 'build_all_zonelists'
WARNING: mm/built-in.o - Section mismatch: reference to .init.text: from .text between '__build_all_zonelists' (at offset 0x3d4b) and 'build_all_zonelists'

Using http://userweb.kernel.org/~akpm/config-sony.txt

Maybe it wasn't your match which did this, I didn't check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
