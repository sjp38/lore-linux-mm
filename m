From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] mm: add kmalloc_array_node and kcalloc_node
Date: Wed, 27 Sep 2017 04:03:01 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709270358400.30866@nuc-kabylake>
References: <20170927082038.3782-1-jthumshirn@suse.de> <20170927082038.3782-2-jthumshirn@suse.de> <20170927084251.kxves5ce76jz5skr@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927084251.kxves5ce76jz5skr@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>
List-Id: linux-mm.kvack.org

On Wed, 27 Sep 2017, Michal Hocko wrote:

> > Introduce a combination of the two above cases to have a NUMA-node aware
> > version of kmalloc_array() and kcalloc().
>
> Yes, this is helpful. I am just wondering why we cannot have
> kmalloc_array to call kmalloc_array_node with the local node as a
> parameter. Maybe some sort of an optimization?

Well the regular kmalloc without node is supposed to follow memory
policies. An explicit mentioning of a node requires allocation from that
node and will override memory allocation policies.

Note that node local policy is the default for allocations but that can be
overridden by the application or at the command line level. Assumptions
that this is always the case come up frequently but if we do that we will
loose the ability to control memory locality for user space.
