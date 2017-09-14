From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when kernel
 panic
Date: Thu, 14 Sep 2017 12:32:53 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709141231430.529@nuc-kabylake>
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com> <1505409289-57031-4-git-send-email-yang.s@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505409289-57031-4-git-send-email-yang.s@alibaba-inc.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

I am not sure that this is generally useful at OOM times unless this is
not a rare occurrence.

Certainly information like that would create more support for making
objects movable.
