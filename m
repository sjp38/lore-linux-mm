From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Date: Tue, 10 Oct 2017 10:14:20 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710101013270.15140@nuc-kabylake>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com> <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz> <221a1e93-ee33-d598-67de-d6071f192040@intel.com> <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz> <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
 <bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com> <20171010143113.gk6iqcrguefhhlmr@dhcp22.suse.cz> <eb9248f9-1941-57f9-de9e-596b4ead6491@linux.intel.com> <20171010145728.q2levvekbpwlg57q@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20171010145728.q2levvekbpwlg57q@dhcp22.suse.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kemi <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Tue, 10 Oct 2017, Michal Hocko wrote:

> > But, let's be honest, this leaves us with an option that nobody is ever
> > going to turn on.  IOW, nobody except a very small portion of our users
> > will ever see any benefit from this.
>
> But aren't those small groups who would like to squeeze every single
> cycle out from the page allocator path the targeted audience?

Those have long sine raised the white flag and succumbed to the
featuritis. Resigned to try to keep the bloat restricted to a couple of
cores so that the rest of the cores stay usable.
