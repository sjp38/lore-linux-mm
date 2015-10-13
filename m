Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D1D396B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:51:45 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so16924190pad.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:51:45 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id rn4si3937674pbc.138.2015.10.13.02.51.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 02:51:45 -0700 (PDT)
Received: by padew5 with SMTP id ew5so1604107pad.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:51:45 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [RFC] arm: add __initbss section attribute
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <5369261.8uuGVmeUFP@wuerfel>
Date: Tue, 13 Oct 2015 17:51:32 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <8004E8C3-F1EC-45C3-A995-88726B257563@gmail.com>
References: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com> <20151012200422.GA29175@ravnborg.org> <FEDC4251-5A6A-4E3C-AE36-8E5B55D9D6CF@gmail.com> <5369261.8uuGVmeUFP@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Sam Ravnborg <sam@ravnborg.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, Victor Kamensky <victor.kamensky@linaro.org>, Mark Salter <msalter@redhat.com>, vladimir.murzin@arm.com, ggdavisiv@gmail.com, paul.gortmaker@windriver.com, mingo@kernel.org, rusty@rustcorp.com.au, mcgrof@suse.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, jack@suse.cz, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org


> On Oct 13, 2015, at 17:40, Arnd Bergmann <arnd@arndb.de> wrote:
>=20
> On Tuesday 13 October 2015 15:33:10 yalin wang wrote:
>>=20
>>> On Oct 13, 2015, at 04:04, Sam Ravnborg <sam@ravnborg.org> wrote:
>>>=20
>>>> --- a/include/asm-generic/vmlinux.lds.h
>>>> +++ b/include/asm-generic/vmlinux.lds.h
>>>>=20
>>>> -#define BSS_SECTION(sbss_align, bss_align, stop_align)			=
\
>>>> +#define BSS_SECTION(sbss_align, bss_align, initbss_align, =
stop_align)			\
>>>=20
>>> A few comments:
>>>=20
>>> 1) - please align the backslash at the end of the
>>>    line with the backslash above it.
>>> 2) - you need to fix all the remaining users of BSS_SECTION.
>>> 3) - do we really need the flexibility to specify an alignment =
(stop_align)?
>>>       If not - drop the extra argument.
>>>=20
>>> 	Sam
>> i change lots of __initdata to __initbss to test it on ARM arch,
>>=20
>=20
> Ok, I found my mistake in the script I used to calculate the savings,
> here is the correct output showing all uninitialized variables in
> multi_v7_defconfig:
>=20
> 4	done.44688
> 1024	boot_command_line
> 1024	tmp_cmdline.44689
> 4	late_time_init
> 4	root_mount_data
> 4	root_fs_names
> 4	rd_doload
> 4	root_delay
> 64	saved_root_name
> 4	root_device_name
> 4	message
> 4	byte_count
> 4	victim
> 4	collected
> 8	this_header
> 4	state
> 4	collect
> 4	remains
> 4	next_state
> 8	header_buf
> 8	next_header
> 4	do_retain_initrd
> 4	name_len
> 4	body_len
> 4	gid
> 4	uid
> 4	mtime
> 4	wfd
> 4	vcollected
> 4	ino
> 4	mode
> 4	nlink
> 4	major
> 4	minor
> 4	rdev
> 4	symlink_buf
> 4	name_buf
> 64	msg_buf.29770
> 128	head
> 4	machine_desc
> 4	usermem.34390
> 4	__atags_pointer
> 1024	cmd_line
> 1024	default_command_line
> 1536	atags_copy
> 4	dma_mmu_remap_num
> 64	dma_mmu_remap
> 4	phys_initrd_start
> 4024	phys_initrd_size
> 4096	bm_pte
> 4	ecc_mask
> 4	initial_pmd_value
> 4	arm_lowmem_limit
> 24	s5p_mfc_mem
> 28	tx_pad_name
> 4	use_gptimer_clksrc
> 4	omap_table_init
> 4	mpurate
> 4	am35xx_aes_hwmod_ocp_ifs
> 4	am35xx_sham_hwmod_ocp_ifs
> 4	dra72x_hwmod_ocp_ifs
> 4	rx51_vibra_data
> 4	num_special_pds
> 128	special_pds
> 4	main_extable_sort_needed
> 4	new_log_buf_len
> 24	opts.36513
> 512	smap.22469
> 512	dmap.22470
> 64	group_map.22521
> 64	group_cnt.22522
> 4	pcpu_chosen_fc
> 4	vmlist
> 4	vm_init_off.26867
> 4	reset_managed_pages_done
> 116	boot_kmem_cache_node.32827
> 116	boot_kmem_cache.32826
> 4	dhash_entries
> 4	ihash_entries
> 4	mhash_entries
> 4	mphash_entries
> 256	nfs_root_parms
> 1028	nfs_export_path
> 1028	nfs_root_device
> 4	gic_cnt
> 4	threshold_index
> 4096	ata_force_param_buf
> 4	mtd_devs
> 2432	mtd_dev_param
> 8	m68k_probes
> 8	isa_probes
> 4	arch_timers_present
> 4	dt_root_size_cells
> 4	dt_root_addr_cells
> 4	imx_keep_uart_clocks
> 4	imx_uart_clocks
> 4	mt8173_top_clk_data
> 4	mt8173_pll_clk_data
> 4	cpg_mode
> 4	cpg_mode_rates
> 4	cpg_mode_divs
> 4	cpg_mode
> 4	cpg_mode
> 4	thash_entries
> 4	uhash_entries
> 4	ic_got_reply
> 4	ic_first_dev
> 4	ic_dev
> 16	user_dev_name
> 4	ic_dhcp_msgtype
> 4	ic_host_name_set
> 4	ic_dev_mtu
> 4	ic_set_manually
> 4	ic_enable
> 256	vendor_class_identifier
> 4	ic_proto_have_if
> 4	dma_reserve
> 4	nr_kernel_pages
> 4	nr_all_pages
> 196	__clk_of_table_sentinel
> 200	__rmem_of_table_sentinel
> 196	__clksrc_of_table_sentinel
> 200	__iommu_of_table_sentinel
> 8	__cpu_method_of_table_sentinel
> 8	__cpuidle_method_of_table_sentinel
> 196	irqchip_of_match_end
> 32	__earlycon_table_sentinel
> 200	__earlycon_of_table_sentinel
> 6	__irf_end
>=20
>=20
> 26398 total
i am curious about your scripts ,
could you show me ?
Thank you !




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
