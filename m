Received: by nf-out-0910.google.com with SMTP id x30so1994106nfb
        for <linux-mm@kvack.org>; Mon, 21 Aug 2006 11:52:39 -0700 (PDT)
Message-ID: <a762e240608211152x5d4f11f0wd26f7e3d75d38e0a@mail.gmail.com>
Date: Mon, 21 Aug 2006 11:52:39 -0700
From: "Keith Mannthey" <kmannth@gmail.com>
Subject: Re: [PATCH 0/6] Sizing zones and holes in an architecture independent manner V9
In-Reply-To: <20060821134518.22179.46355.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060821134518.22179.46355.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, tony.luck@intel.com, linux-mm@kvack.org, ak@suse.de, bob.picco@hp.com, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On 8/21/06, Mel Gorman <mel@csn.ul.ie> wrote:
> This is V9 of the patchset to size zones and memory holes in an
> architecture-independent manner. It booted successfully on 5 different
> machines (arches were x86, x86_64, ppc64 and ia64) in a number of different
> configurations and successfully built a kernel. If it fails on any machine,
> booting with loglevel=8 and the console log should tell me what went wrong.
>

I am wondering why this new api didn't cleanup the pfn_to_nid code
path as well. Arches are left to still keep another set of
nid-start-end info around. We are sending info like

add_active_range(unsigned int nid, unsigned long start_pfn, unsigned
long end_pfn)

With this info making a common pnf_to_nid seems to be of intrest so we
don't have to keep redundant information in both generic and arch
specific data structures.

Are you intending the hot-add memory code path to call add_active_range or ???

Thanks,
  Keith

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
