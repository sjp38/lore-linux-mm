From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
Date: Tue, 18 Jul 2017 09:57:44 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707180957160.2783@nuc-kabylake>
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com> <20170717175459.GC14983@bombadil.infradead.org> <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake> <c86c66c3-29d8-0b04-b4d1-f9f8192d8c4a@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c86c66c3-29d8-0b04-b4d1-f9f8192d8c4a@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexander Popov <alex.popov@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org
List-Id: linux-mm.kvack.org

On Mon, 17 Jul 2017, Alexander Popov wrote:

> Christopher, if I change BUG_ON() to VM_BUG_ON(), it will be disabled by default
> again, right?

It will be enabled if the distro ships with VM debugging on by default.
