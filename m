From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/5] mm: slub: constify attribute_group structures.
Date: Thu, 27 Jul 2017 09:36:41 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707270936260.14168@nuc-kabylake>
References: <1501157186-3749-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501157186-3749-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, 27 Jul 2017, Arvind Yadav wrote:

> attribute_group are not supposed to change at runtime. All functions
> working with attribute_group provided by <linux/sysfs.h> work with
> const attribute_group. So mark the non-const structs as const.

Acked-by: Christoph Lameter <cl@linux.com>
