From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm/slub: don't use reserved memory for optimistic
 try
Date: Wed, 6 Sep 2017 10:55:30 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709061054220.13344@nuc-kabylake>
References: <1504672666-19682-1-git-send-email-iamjoonsoo.kim@lge.com> <1504672666-19682-2-git-send-email-iamjoonsoo.kim@lge.com> <f3af7a0e-d04d-e47d-12c6-8e379d04265a@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f3af7a0e-d04d-e47d-12c6-8e379d04265a@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Vlastimil Babka <vbabka@suse.cz>
Cc: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
List-Id: linux-mm.kvack.org

On Wed, 6 Sep 2017, Vlastimil Babka wrote:

> I think it's wasteful to do a function call for this, inline definition
> in header would be better (gfp_pfmemalloc_allowed() is different as it
> relies on a rather heavyweight __gfp_pfmemalloc_flags().

Right.
