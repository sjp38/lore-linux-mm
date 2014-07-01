From: Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
	handler.
Date: Tue, 1 Jul 2014 11:15:35 +0200
Message-ID: <20140701091535.GF26537@8bytes.org>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
	<1403920822-14488-2-git-send-email-j.glisse@gmail.com>
	<019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
	<20140630154042.GD26537@8bytes.org>
	<20140630160604.GF1956@gmail.com>
	<20140630181623.GE26537@8bytes.org>
	<20140630183556.GB3280@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140630183556.GB3280-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerome Glisse <j.glisse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Sherry Cheung <SCheung-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "Gabbay,
	Oded" <Oded.Gabbay-5C7GfCeVMHo@public.gmane.org>, "hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, "aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jatin Kumar <jakumar-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Lucien Dunning <ldunning-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "mgorman-l3A5Bk7waGM@public.gmane.org" <mgorman-l3A5Bk7waGM@public.gmane.org>, "jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Subhash Gutti <sgutti-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, John Hubbard <jhubbard-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Mark Hairgrove <mhairgrove-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Cameron Buschardt <cabuschardt-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "peterz-hDdKplPs4pWWVfeAwA7xHQ@public.gmane.org" <peterz-hDdKplPs4pWWVfeAwA7xHQ@public.gmane.org>, Duncan Poole <dpoole-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "Cornwall,
	Jay" <Jay.Cornwall-5C7GfCeVMHo@public.gmane.org>, "Lewycky, Andrew" <Andrew.Lewycky-5C7GfCeVMHo@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Arvind Gopalakrishnan <arvindg-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Jun 30, 2014 at 02:35:57PM -0400, Jerome Glisse wrote:
> We do intend to tear down all secondary mapping inside the relase
> callback but still we can not cleanup all the resources associated
> with it.
>

And why can't you cleanup the other resources in the file close path?
Tearing down the mappings is all you need to do in the release function
anyway.

> As said from the release call back you can not call
> mmu_notifier_unregister and thus you can not fully cleanup things.

You don't need to call mmu_notifier_unregister when the release function
is already running from exit_mmap because this is equivalent to calling
mmu_notifier_unregister.

> Only way to achieve so is to do it ouside mmu_notifier callback.

The resources that can't be handled there can be cleaned up in the
file-close path. No need for a new notifier in mm code.

In the end all you need to do in the release function is to tear down
the secondary mapping and make sure the device can no longer access the
address space when the release function returns. Everything else, like
freeing any resources can be done later when the file descriptors are
teared down.

> If you know any other way to call mmu_notifier_unregister before the
> end of mmput function than i am all ear. I am not adding this call
> back just for the fun of it i spend serious time trying to find a
> way to do thing without it. I might have miss a way so if i did please
> show it to me.

Why do you need to call mmu_notifier_unregister manually when it is done
implicitly in exit_mmap already? 


	Joerg
