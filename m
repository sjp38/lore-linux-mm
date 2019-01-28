From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages
 fallouts.
Date: Mon, 28 Jan 2019 09:50:54 -0800
Message-ID: <20190128095054.4103093dec81f1c904df7929@linux-foundation.org>
References: <20190128144506.15603-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190128144506.15603-1-mhocko@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Mon, 28 Jan 2019 15:45:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> have pushed back on those fixes because I believed that it is much
> better to plug the problem at the initialization time rather than play
> whack-a-mole all over the hotplug code and find all the places which
> expect the full memory section to be initialized. We have ended up with
> 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> memory section") merged and cause a regression [2][3]. The reason is
> that there might be memory layouts when two NUMA nodes share the same
> memory section so the merged fix is simply incorrect.
> 
> In order to plug this hole we really have to be zone range aware in
> those handlers. I have split up the original patch into two. One is
> unchanged (patch 2) and I took a different approach for `removable'
> crash. It would be great if Mikhail could test it still works for his
> memory layout.
> 
> [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz

Any thoughts on which kernel version(s) need these patches?
