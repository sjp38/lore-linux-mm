Date: Tue, 4 Apr 2006 19:37:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/6] Swapless V1: Rip out swap migration code
Message-Id: <20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	<20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Mon, 3 Apr 2006 23:58:05 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Rip the page migration logic out
> 

Thank you. I like this removal, especially removing remove_from_swap() :)

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
