From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
Date: Wed, 27 Sep 2017 16:59:31 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709271655330.3643@nuc-kabylake>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com> <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com> <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake> <c7459b93-4197-6968-6735-a97a06325d04@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c7459b93-4197-6968-6735-a97a06325d04@alibaba-inc.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, 28 Sep 2017, Yang Shi wrote:
> > CONFIG_SLABINFO? How does this relate to the oom info? /proc/slabinfo
> > support is optional. Oom info could be included even if CONFIG_SLABINFO
> > goes away. Remove the #ifdef?
>
> Because we want to dump the unreclaimable slab info in oom info.

CONFIG_SLABINFO and /proc/slabinfo have nothing to do with the
unreclaimable slab info.
