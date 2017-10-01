From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
Date: Sun, 1 Oct 2017 01:43:45 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710010142420.25658@nuc-kabylake>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com> <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com> <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake> <c7459b93-4197-6968-6735-a97a06325d04@alibaba-inc.com>
 <alpine.DEB.2.20.1709271655330.3643@nuc-kabylake> <b023b5f4-84b5-1686-7b15-c9a3a439b8be@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b023b5f4-84b5-1686-7b15-c9a3a439b8be@alibaba-inc.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, 28 Sep 2017, Yang Shi wrote:

> > CONFIG_SLABINFO and /proc/slabinfo have nothing to do with the
> > unreclaimable slab info.
>
> The current design uses "struct slabinfo" and get_slabinfo() to retrieve some
> info, i.e. active objs, etc. They are protected by CONFIG_SLABINFO.

Ok I guess then those need to be moved out of CONFIG_SLABINFO. Otherwise
dumping of slabs will not be supported when disabling that option.

Or dump CONFIG_SLABINFO ..
