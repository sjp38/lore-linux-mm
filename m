Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14F2D6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 23:21:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id k4so6406003pgq.15
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 20:21:52 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g17si11364681plo.339.2018.01.09.20.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 20:21:50 -0800 (PST)
Date: Wed, 10 Jan 2018 12:21:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [aaron:for_lkp_skl_2sp2_test 151/225]
 drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1188:116: error:
 '__GFP_COLD' undeclared
Message-ID: <20180110042148.x3nfjnkttdu3irib@wfg-t540p.sh.intel.com>
References: <201801100639.1FfQRG2U%fengguang.wu@intel.com>
 <1515548125.31639.2.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1515548125.31639.2.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Lu, Aaron" <aaron.lu@intel.com>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Jan 10, 2018 at 09:34:47AM +0800, Aaron Lu wrote:
>Please ignore this build report.
>
>I thought the robot has done its job but looks like it is still
>building that branch.

Sorry about that! Although most reports will be caught in the 24 hour,
the 0-day build bot will nowadays typically continue tests for weeks
to improve coverage.

Thanks,
Fengguang

>I just removed the branch, there should be no more such reports.
>
>On Wed, 2018-01-10 at 06:33 +0800, kbuild test robot wrote:
>> tree:   aaron/for_lkp_skl_2sp2_test
>> head:   6c9381b65892222cbe2214fb22af9043f9ce1065
>> commit: cebd3951aaa6936a2dd70e925a5d5667b896da23 [151/225] mm: remove __GFP_COLD
>> config: i386-allyesconfig (attached as .config)
>> compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
>> reproduce:
>>         git checkout cebd3951aaa6936a2dd70e925a5d5667b896da23
>>         # save the attached .config to linux build tree
>>         make ARCH=i386
>>
>> All errors (new ones prefixed by >>):
>>
>>    drivers/net//ethernet/netronome/nfp/nfp_net_common.c: In function 'nfp_net_rx_alloc_one':
>> > > drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1188:116: error: '__GFP_COLD' undeclared (first use in this function)
>>
>>       page = alloc_page(GFP_KERNEL | __GFP_COLD);
>>                                                                                                                        ^
>>    drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1188:116: note: each undeclared identifier is reported only once for each function it appears in
>>    drivers/net//ethernet/netronome/nfp/nfp_net_common.c: In function 'nfp_net_napi_alloc_one':
>>    drivers/net//ethernet/netronome/nfp/nfp_net_common.c:1215:103: error: '__GFP_COLD' undeclared (first use in this function)
>>       page = alloc_page(GFP_ATOMIC | __GFP_COLD);
>>                                                                                                           ^
>>
>> vim +/__GFP_COLD +1188 drivers/net//ethernet/netronome/nfp/nfp_net_common.c
>>
>> ecd63a0217 Jakub Kicinski 2016-11-03  1169
>> 4c3523623d Jakub Kicinski 2015-12-01  1170  /**
>> c0f031bc88 Jakub Kicinski 2016-10-31  1171   * nfp_net_rx_alloc_one() - Allocate and map page frag for RX
>> 783496b0dd Jakub Kicinski 2017-03-10  1172   * @dp:		NFP Net data path struct
>> 4c3523623d Jakub Kicinski 2015-12-01  1173   * @dma_addr:	Pointer to storage for DMA address (output param)
>> 4c3523623d Jakub Kicinski 2015-12-01  1174   *
>> c0f031bc88 Jakub Kicinski 2016-10-31  1175   * This function will allcate a new page frag, map it for DMA.
>> 4c3523623d Jakub Kicinski 2015-12-01  1176   *
>> c0f031bc88 Jakub Kicinski 2016-10-31  1177   * Return: allocated page frag or NULL on failure.
>> 4c3523623d Jakub Kicinski 2015-12-01  1178   */
>> d78005a50f Jakub Kicinski 2017-04-27  1179  static void *nfp_net_rx_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
>> 4c3523623d Jakub Kicinski 2015-12-01  1180  {
>> c0f031bc88 Jakub Kicinski 2016-10-31  1181  	void *frag;
>> 4c3523623d Jakub Kicinski 2015-12-01  1182
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10  1183  	if (!dp->xdp_prog) {
>> 2195c2637f Jakub Kicinski 2017-03-10  1184  		frag = netdev_alloc_frag(dp->fl_bufsz);
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10  1185  	} else {
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10  1186  		struct page *page;
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10  1187
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10 @1188  		page = alloc_page(GFP_KERNEL | __GFP_COLD);
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10  1189  		frag = page ? page_address(page) : NULL;
>> 5f0ca2fb71 Jakub Kicinski 2017-10-10  1190  	}
>> c0f031bc88 Jakub Kicinski 2016-10-31  1191  	if (!frag) {
>> 79c12a752c Jakub Kicinski 2017-03-10  1192  		nn_dp_warn(dp, "Failed to alloc receive page frag\n");
>> 4c3523623d Jakub Kicinski 2015-12-01  1193  		return NULL;
>> 4c3523623d Jakub Kicinski 2015-12-01  1194  	}
>> 4c3523623d Jakub Kicinski 2015-12-01  1195
>> c487e6b199 Jakub Kicinski 2017-03-10  1196  	*dma_addr = nfp_net_dma_map_rx(dp, frag);
>> 79c12a752c Jakub Kicinski 2017-03-10  1197  	if (dma_mapping_error(dp->dev, *dma_addr)) {
>> 9dc6b116e2 Jakub Kicinski 2017-03-10  1198  		nfp_net_free_frag(frag, dp->xdp_prog);
>> 79c12a752c Jakub Kicinski 2017-03-10  1199  		nn_dp_warn(dp, "Failed to map DMA RX buffer\n");
>> 4c3523623d Jakub Kicinski 2015-12-01  1200  		return NULL;
>> 4c3523623d Jakub Kicinski 2015-12-01  1201  	}
>> 4c3523623d Jakub Kicinski 2015-12-01  1202
>> c0f031bc88 Jakub Kicinski 2016-10-31  1203  	return frag;
>> 4c3523623d Jakub Kicinski 2015-12-01  1204  }
>> 4c3523623d Jakub Kicinski 2015-12-01  1205
>>
>> :::::: The code at line 1188 was first introduced by commit
>> :::::: 5f0ca2fb71e28df146f590eebfe32b41171b737f nfp: handle page allocation failures
>>
>> :::::: TO: Jakub Kicinski <jakub.kicinski@netronome.com>
>> :::::: CC: David S. Miller <davem@davemloft.net>
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
