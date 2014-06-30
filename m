From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Date: Mon, 30 Jun 2014 17:37:26 +0200
Message-ID: <20140630153726.GC26537@8bytes.org>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: =?iso-8859-1?B?Suly9G1l?= Glisse <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
List-Id: linux-mm.kvack.org

On Fri, Jun 27, 2014 at 10:00:19PM -0400, J=E9r=F4me Glisse wrote:
> Note that this patch also move the call to cleanup functions after
> exit_mmap so that new call back can assume that mmu_notifier_release
> have already been call. This does not impact existing cleanup functio=
ns
> as they do not rely on anything that exit_mmap is freeing. Also moved
> khugepaged_exit to exit_mmap so that ordering is preserved for that
> function.

What this patch does is duplicating the functionality of the
mmu_notifier_release call-back. Why is it needed?


	Joerg
