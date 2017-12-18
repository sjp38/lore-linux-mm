Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9341D6B0069
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 21:37:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f3so10232834pgv.21
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 18:37:25 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o61si8597837pld.253.2017.12.17.18.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Dec 2017 18:37:21 -0800 (PST)
Date: Mon, 18 Dec 2017 10:37:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: drivers/gpu/drm/i915/gvt/handlers.c:2397:1: error: the frame size of
 32120 bytes is larger than 8192 bytes
Message-ID: <201712181000.3Y17BDzn%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   779f4e1c6c7c661db40dfebd6dd6bda7b5f88aa3
commit: d17a1d97dc208d664c91cc387ffb752c7f85dc61 x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
date:   5 weeks ago
config: x86_64-randconfig-x001-12180843 (attached as .config)
compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
reproduce:
        git checkout d17a1d97dc208d664c91cc387ffb752c7f85dc61
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   drivers/gpu/drm/i915/gvt/handlers.c: In function 'init_generic_mmio_info':
>> drivers/gpu/drm/i915/gvt/handlers.c:2397:1: error: the frame size of 32120 bytes is larger than 8192 bytes [-Werror=frame-larger-than=]
    }
    ^
   cc1: all warnings being treated as errors

vim +2397 drivers/gpu/drm/i915/gvt/handlers.c

e39c5add3 Zhi Wang       2016-09-02  1649  
0aa5277c3 Zhao Yan       2017-02-28  1650  	MMIO_RING_DFH(RING_MI_MODE, D_ALL, F_MODE_MASK | F_CMD_ACCESS,
0aa5277c3 Zhao Yan       2017-02-28  1651  		NULL, NULL);
41bfab35b Pei Zhang      2017-02-24  1652  	MMIO_RING_DFH(RING_INSTPM, D_ALL, F_MODE_MASK | F_CMD_ACCESS,
41bfab35b Pei Zhang      2017-02-24  1653  			NULL, NULL);
04d348ae3 Zhi Wang       2016-04-25  1654  	MMIO_RING_DFH(RING_TIMESTAMP, D_ALL, F_CMD_ACCESS,
20a2bcdec Xiong Zhang    2017-10-14  1655  			mmio_read_from_hw, NULL);
04d348ae3 Zhi Wang       2016-04-25  1656  	MMIO_RING_DFH(RING_TIMESTAMP_UDW, D_ALL, F_CMD_ACCESS,
20a2bcdec Xiong Zhang    2017-10-14  1657  			mmio_read_from_hw, NULL);
e39c5add3 Zhi Wang       2016-09-02  1658  
0aa5277c3 Zhao Yan       2017-02-28  1659  	MMIO_DFH(GEN7_GT_MODE, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1660  	MMIO_DFH(CACHE_MODE_0_GEN7, D_ALL, F_MODE_MASK | F_CMD_ACCESS,
0aa5277c3 Zhao Yan       2017-02-28  1661  		NULL, NULL);
a045fba47 Ping Gao       2016-11-14  1662  	MMIO_DFH(CACHE_MODE_1, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1663  	MMIO_DFH(CACHE_MODE_0, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1664  	MMIO_DFH(0x2124, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1665  
0aa5277c3 Zhao Yan       2017-02-28  1666  	MMIO_DFH(0x20dc, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1667  	MMIO_DFH(_3D_CHICKEN3, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1668  	MMIO_DFH(0x2088, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1669  	MMIO_DFH(0x20e4, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1670  	MMIO_DFH(0x2470, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1671  	MMIO_DFH(GAM_ECOCHK, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1672  	MMIO_DFH(GEN7_COMMON_SLICE_CHICKEN1, D_ALL, F_MODE_MASK | F_CMD_ACCESS,
0aa5277c3 Zhao Yan       2017-02-28  1673  		NULL, NULL);
1999f108c Chuanxiao Dong 2017-05-17  1674  	MMIO_DFH(COMMON_SLICE_CHICKEN2, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL,
1999f108c Chuanxiao Dong 2017-05-17  1675  		 skl_misc_ctl_write);
0aa5277c3 Zhao Yan       2017-02-28  1676  	MMIO_DFH(0x9030, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1677  	MMIO_DFH(0x20a0, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1678  	MMIO_DFH(0x2420, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1679  	MMIO_DFH(0x2430, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1680  	MMIO_DFH(0x2434, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1681  	MMIO_DFH(0x2438, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1682  	MMIO_DFH(0x243c, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  1683  	MMIO_DFH(0x7018, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
a045fba47 Ping Gao       2016-11-14  1684  	MMIO_DFH(HALF_SLICE_CHICKEN3, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
187447a10 Pei Zhang      2017-02-21  1685  	MMIO_DFH(GEN7_HALF_SLICE_CHICKEN1, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  1686  
e39c5add3 Zhi Wang       2016-09-02  1687  	/* display */
e39c5add3 Zhi Wang       2016-09-02  1688  	MMIO_F(0x60220, 0x20, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  1689  	MMIO_D(0x602a0, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1690  
e39c5add3 Zhi Wang       2016-09-02  1691  	MMIO_D(0x65050, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1692  	MMIO_D(0x650b4, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1693  
e39c5add3 Zhi Wang       2016-09-02  1694  	MMIO_D(0xc4040, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1695  	MMIO_D(DERRMR, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1696  
e39c5add3 Zhi Wang       2016-09-02  1697  	MMIO_D(PIPEDSL(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1698  	MMIO_D(PIPEDSL(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1699  	MMIO_D(PIPEDSL(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1700  	MMIO_D(PIPEDSL(_PIPE_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1701  
04d348ae3 Zhi Wang       2016-04-25  1702  	MMIO_DH(PIPECONF(PIPE_A), D_ALL, NULL, pipeconf_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1703  	MMIO_DH(PIPECONF(PIPE_B), D_ALL, NULL, pipeconf_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1704  	MMIO_DH(PIPECONF(PIPE_C), D_ALL, NULL, pipeconf_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1705  	MMIO_DH(PIPECONF(_PIPE_EDP), D_ALL, NULL, pipeconf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1706  
e39c5add3 Zhi Wang       2016-09-02  1707  	MMIO_D(PIPESTAT(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1708  	MMIO_D(PIPESTAT(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1709  	MMIO_D(PIPESTAT(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1710  	MMIO_D(PIPESTAT(_PIPE_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1711  
e39c5add3 Zhi Wang       2016-09-02  1712  	MMIO_D(PIPE_FLIPCOUNT_G4X(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1713  	MMIO_D(PIPE_FLIPCOUNT_G4X(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1714  	MMIO_D(PIPE_FLIPCOUNT_G4X(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1715  	MMIO_D(PIPE_FLIPCOUNT_G4X(_PIPE_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1716  
e39c5add3 Zhi Wang       2016-09-02  1717  	MMIO_D(PIPE_FRMCOUNT_G4X(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1718  	MMIO_D(PIPE_FRMCOUNT_G4X(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1719  	MMIO_D(PIPE_FRMCOUNT_G4X(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1720  	MMIO_D(PIPE_FRMCOUNT_G4X(_PIPE_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1721  
e39c5add3 Zhi Wang       2016-09-02  1722  	MMIO_D(CURCNTR(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1723  	MMIO_D(CURCNTR(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1724  	MMIO_D(CURCNTR(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1725  
e39c5add3 Zhi Wang       2016-09-02  1726  	MMIO_D(CURPOS(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1727  	MMIO_D(CURPOS(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1728  	MMIO_D(CURPOS(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1729  
e39c5add3 Zhi Wang       2016-09-02  1730  	MMIO_D(CURBASE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1731  	MMIO_D(CURBASE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1732  	MMIO_D(CURBASE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1733  
e39c5add3 Zhi Wang       2016-09-02  1734  	MMIO_D(0x700ac, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1735  	MMIO_D(0x710ac, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1736  	MMIO_D(0x720ac, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1737  
e39c5add3 Zhi Wang       2016-09-02  1738  	MMIO_D(0x70090, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1739  	MMIO_D(0x70094, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1740  	MMIO_D(0x70098, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1741  	MMIO_D(0x7009c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1742  
e39c5add3 Zhi Wang       2016-09-02  1743  	MMIO_D(DSPCNTR(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1744  	MMIO_D(DSPADDR(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1745  	MMIO_D(DSPSTRIDE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1746  	MMIO_D(DSPPOS(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1747  	MMIO_D(DSPSIZE(PIPE_A), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  1748  	MMIO_DH(DSPSURF(PIPE_A), D_ALL, NULL, pri_surf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1749  	MMIO_D(DSPOFFSET(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1750  	MMIO_D(DSPSURFLIVE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1751  
e39c5add3 Zhi Wang       2016-09-02  1752  	MMIO_D(DSPCNTR(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1753  	MMIO_D(DSPADDR(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1754  	MMIO_D(DSPSTRIDE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1755  	MMIO_D(DSPPOS(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1756  	MMIO_D(DSPSIZE(PIPE_B), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  1757  	MMIO_DH(DSPSURF(PIPE_B), D_ALL, NULL, pri_surf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1758  	MMIO_D(DSPOFFSET(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1759  	MMIO_D(DSPSURFLIVE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1760  
e39c5add3 Zhi Wang       2016-09-02  1761  	MMIO_D(DSPCNTR(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1762  	MMIO_D(DSPADDR(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1763  	MMIO_D(DSPSTRIDE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1764  	MMIO_D(DSPPOS(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1765  	MMIO_D(DSPSIZE(PIPE_C), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  1766  	MMIO_DH(DSPSURF(PIPE_C), D_ALL, NULL, pri_surf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1767  	MMIO_D(DSPOFFSET(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1768  	MMIO_D(DSPSURFLIVE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1769  
e39c5add3 Zhi Wang       2016-09-02  1770  	MMIO_D(SPRCTL(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1771  	MMIO_D(SPRLINOFF(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1772  	MMIO_D(SPRSTRIDE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1773  	MMIO_D(SPRPOS(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1774  	MMIO_D(SPRSIZE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1775  	MMIO_D(SPRKEYVAL(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1776  	MMIO_D(SPRKEYMSK(PIPE_A), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  1777  	MMIO_DH(SPRSURF(PIPE_A), D_ALL, NULL, spr_surf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1778  	MMIO_D(SPRKEYMAX(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1779  	MMIO_D(SPROFFSET(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1780  	MMIO_D(SPRSCALE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1781  	MMIO_D(SPRSURFLIVE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1782  
e39c5add3 Zhi Wang       2016-09-02  1783  	MMIO_D(SPRCTL(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1784  	MMIO_D(SPRLINOFF(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1785  	MMIO_D(SPRSTRIDE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1786  	MMIO_D(SPRPOS(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1787  	MMIO_D(SPRSIZE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1788  	MMIO_D(SPRKEYVAL(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1789  	MMIO_D(SPRKEYMSK(PIPE_B), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  1790  	MMIO_DH(SPRSURF(PIPE_B), D_ALL, NULL, spr_surf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1791  	MMIO_D(SPRKEYMAX(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1792  	MMIO_D(SPROFFSET(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1793  	MMIO_D(SPRSCALE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1794  	MMIO_D(SPRSURFLIVE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1795  
e39c5add3 Zhi Wang       2016-09-02  1796  	MMIO_D(SPRCTL(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1797  	MMIO_D(SPRLINOFF(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1798  	MMIO_D(SPRSTRIDE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1799  	MMIO_D(SPRPOS(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1800  	MMIO_D(SPRSIZE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1801  	MMIO_D(SPRKEYVAL(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1802  	MMIO_D(SPRKEYMSK(PIPE_C), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  1803  	MMIO_DH(SPRSURF(PIPE_C), D_ALL, NULL, spr_surf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1804  	MMIO_D(SPRKEYMAX(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1805  	MMIO_D(SPROFFSET(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1806  	MMIO_D(SPRSCALE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1807  	MMIO_D(SPRSURFLIVE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1808  
e39c5add3 Zhi Wang       2016-09-02  1809  	MMIO_D(HTOTAL(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1810  	MMIO_D(HBLANK(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1811  	MMIO_D(HSYNC(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1812  	MMIO_D(VTOTAL(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1813  	MMIO_D(VBLANK(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1814  	MMIO_D(VSYNC(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1815  	MMIO_D(BCLRPAT(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1816  	MMIO_D(VSYNCSHIFT(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1817  	MMIO_D(PIPESRC(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1818  
e39c5add3 Zhi Wang       2016-09-02  1819  	MMIO_D(HTOTAL(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1820  	MMIO_D(HBLANK(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1821  	MMIO_D(HSYNC(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1822  	MMIO_D(VTOTAL(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1823  	MMIO_D(VBLANK(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1824  	MMIO_D(VSYNC(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1825  	MMIO_D(BCLRPAT(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1826  	MMIO_D(VSYNCSHIFT(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1827  	MMIO_D(PIPESRC(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1828  
e39c5add3 Zhi Wang       2016-09-02  1829  	MMIO_D(HTOTAL(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1830  	MMIO_D(HBLANK(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1831  	MMIO_D(HSYNC(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1832  	MMIO_D(VTOTAL(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1833  	MMIO_D(VBLANK(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1834  	MMIO_D(VSYNC(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1835  	MMIO_D(BCLRPAT(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1836  	MMIO_D(VSYNCSHIFT(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1837  	MMIO_D(PIPESRC(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1838  
e39c5add3 Zhi Wang       2016-09-02  1839  	MMIO_D(HTOTAL(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1840  	MMIO_D(HBLANK(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1841  	MMIO_D(HSYNC(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1842  	MMIO_D(VTOTAL(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1843  	MMIO_D(VBLANK(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1844  	MMIO_D(VSYNC(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1845  	MMIO_D(BCLRPAT(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1846  	MMIO_D(VSYNCSHIFT(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1847  
e39c5add3 Zhi Wang       2016-09-02  1848  	MMIO_D(PIPE_DATA_M1(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1849  	MMIO_D(PIPE_DATA_N1(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1850  	MMIO_D(PIPE_DATA_M2(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1851  	MMIO_D(PIPE_DATA_N2(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1852  	MMIO_D(PIPE_LINK_M1(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1853  	MMIO_D(PIPE_LINK_N1(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1854  	MMIO_D(PIPE_LINK_M2(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1855  	MMIO_D(PIPE_LINK_N2(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1856  
e39c5add3 Zhi Wang       2016-09-02  1857  	MMIO_D(PIPE_DATA_M1(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1858  	MMIO_D(PIPE_DATA_N1(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1859  	MMIO_D(PIPE_DATA_M2(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1860  	MMIO_D(PIPE_DATA_N2(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1861  	MMIO_D(PIPE_LINK_M1(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1862  	MMIO_D(PIPE_LINK_N1(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1863  	MMIO_D(PIPE_LINK_M2(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1864  	MMIO_D(PIPE_LINK_N2(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1865  
e39c5add3 Zhi Wang       2016-09-02  1866  	MMIO_D(PIPE_DATA_M1(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1867  	MMIO_D(PIPE_DATA_N1(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1868  	MMIO_D(PIPE_DATA_M2(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1869  	MMIO_D(PIPE_DATA_N2(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1870  	MMIO_D(PIPE_LINK_M1(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1871  	MMIO_D(PIPE_LINK_N1(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1872  	MMIO_D(PIPE_LINK_M2(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1873  	MMIO_D(PIPE_LINK_N2(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1874  
e39c5add3 Zhi Wang       2016-09-02  1875  	MMIO_D(PIPE_DATA_M1(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1876  	MMIO_D(PIPE_DATA_N1(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1877  	MMIO_D(PIPE_DATA_M2(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1878  	MMIO_D(PIPE_DATA_N2(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1879  	MMIO_D(PIPE_LINK_M1(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1880  	MMIO_D(PIPE_LINK_N1(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1881  	MMIO_D(PIPE_LINK_M2(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1882  	MMIO_D(PIPE_LINK_N2(TRANSCODER_EDP), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1883  
e39c5add3 Zhi Wang       2016-09-02  1884  	MMIO_D(PF_CTL(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1885  	MMIO_D(PF_WIN_SZ(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1886  	MMIO_D(PF_WIN_POS(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1887  	MMIO_D(PF_VSCALE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1888  	MMIO_D(PF_HSCALE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1889  
e39c5add3 Zhi Wang       2016-09-02  1890  	MMIO_D(PF_CTL(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1891  	MMIO_D(PF_WIN_SZ(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1892  	MMIO_D(PF_WIN_POS(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1893  	MMIO_D(PF_VSCALE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1894  	MMIO_D(PF_HSCALE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1895  
e39c5add3 Zhi Wang       2016-09-02  1896  	MMIO_D(PF_CTL(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1897  	MMIO_D(PF_WIN_SZ(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1898  	MMIO_D(PF_WIN_POS(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1899  	MMIO_D(PF_VSCALE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1900  	MMIO_D(PF_HSCALE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1901  
e39c5add3 Zhi Wang       2016-09-02  1902  	MMIO_D(WM0_PIPEA_ILK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1903  	MMIO_D(WM0_PIPEB_ILK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1904  	MMIO_D(WM0_PIPEC_IVB, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1905  	MMIO_D(WM1_LP_ILK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1906  	MMIO_D(WM2_LP_ILK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1907  	MMIO_D(WM3_LP_ILK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1908  	MMIO_D(WM1S_LP_ILK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1909  	MMIO_D(WM2S_LP_IVB, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1910  	MMIO_D(WM3S_LP_IVB, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1911  
e39c5add3 Zhi Wang       2016-09-02  1912  	MMIO_D(BLC_PWM_CPU_CTL2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1913  	MMIO_D(BLC_PWM_CPU_CTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1914  	MMIO_D(BLC_PWM_PCH_CTL1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1915  	MMIO_D(BLC_PWM_PCH_CTL2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1916  
e39c5add3 Zhi Wang       2016-09-02  1917  	MMIO_D(0x48268, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1918  
04d348ae3 Zhi Wang       2016-04-25  1919  	MMIO_F(PCH_GMBUS0, 4 * 4, 0, 0, 0, D_ALL, gmbus_mmio_read,
04d348ae3 Zhi Wang       2016-04-25  1920  		gmbus_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1921  	MMIO_F(PCH_GPIOA, 6 * 4, F_UNALIGN, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  1922  	MMIO_F(0xe4f00, 0x28, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  1923  
04d348ae3 Zhi Wang       2016-04-25  1924  	MMIO_F(_PCH_DPB_AUX_CH_CTL, 6 * 4, 0, 0, 0, D_PRE_SKL, NULL,
04d348ae3 Zhi Wang       2016-04-25  1925  		dp_aux_ch_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1926  	MMIO_F(_PCH_DPC_AUX_CH_CTL, 6 * 4, 0, 0, 0, D_PRE_SKL, NULL,
04d348ae3 Zhi Wang       2016-04-25  1927  		dp_aux_ch_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1928  	MMIO_F(_PCH_DPD_AUX_CH_CTL, 6 * 4, 0, 0, 0, D_PRE_SKL, NULL,
04d348ae3 Zhi Wang       2016-04-25  1929  		dp_aux_ch_ctl_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1930  
75e64ff2c Xiong Zhang    2017-06-28  1931  	MMIO_DH(PCH_ADPA, D_PRE_SKL, NULL, pch_adpa_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1932  
04d348ae3 Zhi Wang       2016-04-25  1933  	MMIO_DH(_PCH_TRANSACONF, D_ALL, NULL, transconf_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1934  	MMIO_DH(_PCH_TRANSBCONF, D_ALL, NULL, transconf_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1935  
04d348ae3 Zhi Wang       2016-04-25  1936  	MMIO_DH(FDI_RX_IIR(PIPE_A), D_ALL, NULL, fdi_rx_iir_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1937  	MMIO_DH(FDI_RX_IIR(PIPE_B), D_ALL, NULL, fdi_rx_iir_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1938  	MMIO_DH(FDI_RX_IIR(PIPE_C), D_ALL, NULL, fdi_rx_iir_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  1939  	MMIO_DH(FDI_RX_IMR(PIPE_A), D_ALL, NULL, update_fdi_rx_iir_status);
04d348ae3 Zhi Wang       2016-04-25  1940  	MMIO_DH(FDI_RX_IMR(PIPE_B), D_ALL, NULL, update_fdi_rx_iir_status);
04d348ae3 Zhi Wang       2016-04-25  1941  	MMIO_DH(FDI_RX_IMR(PIPE_C), D_ALL, NULL, update_fdi_rx_iir_status);
04d348ae3 Zhi Wang       2016-04-25  1942  	MMIO_DH(FDI_RX_CTL(PIPE_A), D_ALL, NULL, update_fdi_rx_iir_status);
04d348ae3 Zhi Wang       2016-04-25  1943  	MMIO_DH(FDI_RX_CTL(PIPE_B), D_ALL, NULL, update_fdi_rx_iir_status);
04d348ae3 Zhi Wang       2016-04-25  1944  	MMIO_DH(FDI_RX_CTL(PIPE_C), D_ALL, NULL, update_fdi_rx_iir_status);
e39c5add3 Zhi Wang       2016-09-02  1945  
e39c5add3 Zhi Wang       2016-09-02  1946  	MMIO_D(_PCH_TRANS_HTOTAL_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1947  	MMIO_D(_PCH_TRANS_HBLANK_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1948  	MMIO_D(_PCH_TRANS_HSYNC_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1949  	MMIO_D(_PCH_TRANS_VTOTAL_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1950  	MMIO_D(_PCH_TRANS_VBLANK_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1951  	MMIO_D(_PCH_TRANS_VSYNC_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1952  	MMIO_D(_PCH_TRANS_VSYNCSHIFT_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1953  
e39c5add3 Zhi Wang       2016-09-02  1954  	MMIO_D(_PCH_TRANS_HTOTAL_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1955  	MMIO_D(_PCH_TRANS_HBLANK_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1956  	MMIO_D(_PCH_TRANS_HSYNC_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1957  	MMIO_D(_PCH_TRANS_VTOTAL_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1958  	MMIO_D(_PCH_TRANS_VBLANK_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1959  	MMIO_D(_PCH_TRANS_VSYNC_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1960  	MMIO_D(_PCH_TRANS_VSYNCSHIFT_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1961  
e39c5add3 Zhi Wang       2016-09-02  1962  	MMIO_D(_PCH_TRANSA_DATA_M1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1963  	MMIO_D(_PCH_TRANSA_DATA_N1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1964  	MMIO_D(_PCH_TRANSA_DATA_M2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1965  	MMIO_D(_PCH_TRANSA_DATA_N2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1966  	MMIO_D(_PCH_TRANSA_LINK_M1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1967  	MMIO_D(_PCH_TRANSA_LINK_N1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1968  	MMIO_D(_PCH_TRANSA_LINK_M2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1969  	MMIO_D(_PCH_TRANSA_LINK_N2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1970  
e39c5add3 Zhi Wang       2016-09-02  1971  	MMIO_D(TRANS_DP_CTL(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1972  	MMIO_D(TRANS_DP_CTL(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1973  	MMIO_D(TRANS_DP_CTL(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1974  
e39c5add3 Zhi Wang       2016-09-02  1975  	MMIO_D(TVIDEO_DIP_CTL(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1976  	MMIO_D(TVIDEO_DIP_DATA(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1977  	MMIO_D(TVIDEO_DIP_GCP(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1978  
e39c5add3 Zhi Wang       2016-09-02  1979  	MMIO_D(TVIDEO_DIP_CTL(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1980  	MMIO_D(TVIDEO_DIP_DATA(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1981  	MMIO_D(TVIDEO_DIP_GCP(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1982  
e39c5add3 Zhi Wang       2016-09-02  1983  	MMIO_D(TVIDEO_DIP_CTL(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1984  	MMIO_D(TVIDEO_DIP_DATA(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1985  	MMIO_D(TVIDEO_DIP_GCP(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1986  
e39c5add3 Zhi Wang       2016-09-02  1987  	MMIO_D(_FDI_RXA_MISC, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1988  	MMIO_D(_FDI_RXB_MISC, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1989  	MMIO_D(_FDI_RXA_TUSIZE1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1990  	MMIO_D(_FDI_RXA_TUSIZE2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1991  	MMIO_D(_FDI_RXB_TUSIZE1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1992  	MMIO_D(_FDI_RXB_TUSIZE2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1993  
04d348ae3 Zhi Wang       2016-04-25  1994  	MMIO_DH(PCH_PP_CONTROL, D_ALL, NULL, pch_pp_control_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  1995  	MMIO_D(PCH_PP_DIVISOR, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1996  	MMIO_D(PCH_PP_STATUS,  D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1997  	MMIO_D(PCH_LVDS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1998  	MMIO_D(_PCH_DPLL_A, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  1999  	MMIO_D(_PCH_DPLL_B, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2000  	MMIO_D(_PCH_FPA0, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2001  	MMIO_D(_PCH_FPA1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2002  	MMIO_D(_PCH_FPB0, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2003  	MMIO_D(_PCH_FPB1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2004  	MMIO_D(PCH_DREF_CONTROL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2005  	MMIO_D(PCH_RAWCLK_FREQ, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2006  	MMIO_D(PCH_DPLL_SEL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2007  
e39c5add3 Zhi Wang       2016-09-02  2008  	MMIO_D(0x61208, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2009  	MMIO_D(0x6120c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2010  	MMIO_D(PCH_PP_ON_DELAYS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2011  	MMIO_D(PCH_PP_OFF_DELAYS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2012  
04d348ae3 Zhi Wang       2016-04-25  2013  	MMIO_DH(0xe651c, D_ALL, dpy_reg_mmio_read, NULL);
04d348ae3 Zhi Wang       2016-04-25  2014  	MMIO_DH(0xe661c, D_ALL, dpy_reg_mmio_read, NULL);
04d348ae3 Zhi Wang       2016-04-25  2015  	MMIO_DH(0xe671c, D_ALL, dpy_reg_mmio_read, NULL);
04d348ae3 Zhi Wang       2016-04-25  2016  	MMIO_DH(0xe681c, D_ALL, dpy_reg_mmio_read, NULL);
5cd82b757 Changbin Du    2017-06-13  2017  	MMIO_DH(0xe6c04, D_ALL, dpy_reg_mmio_read, NULL);
5cd82b757 Changbin Du    2017-06-13  2018  	MMIO_DH(0xe6e1c, D_ALL, dpy_reg_mmio_read, NULL);
e39c5add3 Zhi Wang       2016-09-02  2019  
e39c5add3 Zhi Wang       2016-09-02  2020  	MMIO_RO(PCH_PORT_HOTPLUG, D_ALL, 0,
e39c5add3 Zhi Wang       2016-09-02  2021  		PORTA_HOTPLUG_STATUS_MASK
e39c5add3 Zhi Wang       2016-09-02  2022  		| PORTB_HOTPLUG_STATUS_MASK
e39c5add3 Zhi Wang       2016-09-02  2023  		| PORTC_HOTPLUG_STATUS_MASK
e39c5add3 Zhi Wang       2016-09-02  2024  		| PORTD_HOTPLUG_STATUS_MASK,
e39c5add3 Zhi Wang       2016-09-02  2025  		NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2026  
04d348ae3 Zhi Wang       2016-04-25  2027  	MMIO_DH(LCPLL_CTL, D_ALL, NULL, lcpll_ctl_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2028  	MMIO_D(FUSE_STRAP, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2029  	MMIO_D(DIGITAL_PORT_HOTPLUG_CNTRL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2030  
e39c5add3 Zhi Wang       2016-09-02  2031  	MMIO_D(DISP_ARB_CTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2032  	MMIO_D(DISP_ARB_CTL2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2033  
e39c5add3 Zhi Wang       2016-09-02  2034  	MMIO_D(ILK_DISPLAY_CHICKEN1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2035  	MMIO_D(ILK_DISPLAY_CHICKEN2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2036  	MMIO_D(ILK_DSPCLK_GATE_D, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2037  
e39c5add3 Zhi Wang       2016-09-02  2038  	MMIO_D(SOUTH_CHICKEN1, D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2039  	MMIO_DH(SOUTH_CHICKEN2, D_ALL, NULL, south_chicken2_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2040  	MMIO_D(_TRANSA_CHICKEN1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2041  	MMIO_D(_TRANSB_CHICKEN1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2042  	MMIO_D(SOUTH_DSPCLK_GATE_D, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2043  	MMIO_D(_TRANSA_CHICKEN2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2044  	MMIO_D(_TRANSB_CHICKEN2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2045  
e39c5add3 Zhi Wang       2016-09-02  2046  	MMIO_D(ILK_DPFC_CB_BASE, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2047  	MMIO_D(ILK_DPFC_CONTROL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2048  	MMIO_D(ILK_DPFC_RECOMP_CTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2049  	MMIO_D(ILK_DPFC_STATUS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2050  	MMIO_D(ILK_DPFC_FENCE_YOFF, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2051  	MMIO_D(ILK_DPFC_CHICKEN, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2052  	MMIO_D(ILK_FBC_RT_BASE, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2053  
e39c5add3 Zhi Wang       2016-09-02  2054  	MMIO_D(IPS_CTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2055  
e39c5add3 Zhi Wang       2016-09-02  2056  	MMIO_D(PIPE_CSC_COEFF_RY_GY(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2057  	MMIO_D(PIPE_CSC_COEFF_BY(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2058  	MMIO_D(PIPE_CSC_COEFF_RU_GU(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2059  	MMIO_D(PIPE_CSC_COEFF_BU(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2060  	MMIO_D(PIPE_CSC_COEFF_RV_GV(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2061  	MMIO_D(PIPE_CSC_COEFF_BV(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2062  	MMIO_D(PIPE_CSC_MODE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2063  	MMIO_D(PIPE_CSC_PREOFF_HI(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2064  	MMIO_D(PIPE_CSC_PREOFF_ME(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2065  	MMIO_D(PIPE_CSC_PREOFF_LO(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2066  	MMIO_D(PIPE_CSC_POSTOFF_HI(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2067  	MMIO_D(PIPE_CSC_POSTOFF_ME(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2068  	MMIO_D(PIPE_CSC_POSTOFF_LO(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2069  
e39c5add3 Zhi Wang       2016-09-02  2070  	MMIO_D(PIPE_CSC_COEFF_RY_GY(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2071  	MMIO_D(PIPE_CSC_COEFF_BY(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2072  	MMIO_D(PIPE_CSC_COEFF_RU_GU(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2073  	MMIO_D(PIPE_CSC_COEFF_BU(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2074  	MMIO_D(PIPE_CSC_COEFF_RV_GV(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2075  	MMIO_D(PIPE_CSC_COEFF_BV(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2076  	MMIO_D(PIPE_CSC_MODE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2077  	MMIO_D(PIPE_CSC_PREOFF_HI(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2078  	MMIO_D(PIPE_CSC_PREOFF_ME(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2079  	MMIO_D(PIPE_CSC_PREOFF_LO(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2080  	MMIO_D(PIPE_CSC_POSTOFF_HI(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2081  	MMIO_D(PIPE_CSC_POSTOFF_ME(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2082  	MMIO_D(PIPE_CSC_POSTOFF_LO(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2083  
e39c5add3 Zhi Wang       2016-09-02  2084  	MMIO_D(PIPE_CSC_COEFF_RY_GY(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2085  	MMIO_D(PIPE_CSC_COEFF_BY(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2086  	MMIO_D(PIPE_CSC_COEFF_RU_GU(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2087  	MMIO_D(PIPE_CSC_COEFF_BU(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2088  	MMIO_D(PIPE_CSC_COEFF_RV_GV(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2089  	MMIO_D(PIPE_CSC_COEFF_BV(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2090  	MMIO_D(PIPE_CSC_MODE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2091  	MMIO_D(PIPE_CSC_PREOFF_HI(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2092  	MMIO_D(PIPE_CSC_PREOFF_ME(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2093  	MMIO_D(PIPE_CSC_PREOFF_LO(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2094  	MMIO_D(PIPE_CSC_POSTOFF_HI(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2095  	MMIO_D(PIPE_CSC_POSTOFF_ME(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2096  	MMIO_D(PIPE_CSC_POSTOFF_LO(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2097  
04d348ae3 Zhi Wang       2016-04-25  2098  	MMIO_D(PREC_PAL_INDEX(PIPE_A), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2099  	MMIO_D(PREC_PAL_DATA(PIPE_A), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2100  	MMIO_F(PREC_PAL_GC_MAX(PIPE_A, 0), 4 * 3, 0, 0, 0, D_ALL, NULL, NULL);
04d348ae3 Zhi Wang       2016-04-25  2101  
04d348ae3 Zhi Wang       2016-04-25  2102  	MMIO_D(PREC_PAL_INDEX(PIPE_B), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2103  	MMIO_D(PREC_PAL_DATA(PIPE_B), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2104  	MMIO_F(PREC_PAL_GC_MAX(PIPE_B, 0), 4 * 3, 0, 0, 0, D_ALL, NULL, NULL);
04d348ae3 Zhi Wang       2016-04-25  2105  
04d348ae3 Zhi Wang       2016-04-25  2106  	MMIO_D(PREC_PAL_INDEX(PIPE_C), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2107  	MMIO_D(PREC_PAL_DATA(PIPE_C), D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2108  	MMIO_F(PREC_PAL_GC_MAX(PIPE_C, 0), 4 * 3, 0, 0, 0, D_ALL, NULL, NULL);
04d348ae3 Zhi Wang       2016-04-25  2109  
e39c5add3 Zhi Wang       2016-09-02  2110  	MMIO_D(0x60110, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2111  	MMIO_D(0x61110, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2112  	MMIO_F(0x70400, 0x40, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2113  	MMIO_F(0x71400, 0x40, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2114  	MMIO_F(0x72400, 0x40, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2115  	MMIO_F(0x70440, 0xc, 0, 0, 0, D_PRE_SKL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2116  	MMIO_F(0x71440, 0xc, 0, 0, 0, D_PRE_SKL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2117  	MMIO_F(0x72440, 0xc, 0, 0, 0, D_PRE_SKL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2118  	MMIO_F(0x7044c, 0xc, 0, 0, 0, D_PRE_SKL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2119  	MMIO_F(0x7144c, 0xc, 0, 0, 0, D_PRE_SKL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2120  	MMIO_F(0x7244c, 0xc, 0, 0, 0, D_PRE_SKL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2121  
e39c5add3 Zhi Wang       2016-09-02  2122  	MMIO_D(PIPE_WM_LINETIME(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2123  	MMIO_D(PIPE_WM_LINETIME(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2124  	MMIO_D(PIPE_WM_LINETIME(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2125  	MMIO_D(SPLL_CTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2126  	MMIO_D(_WRPLL_CTL1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2127  	MMIO_D(_WRPLL_CTL2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2128  	MMIO_D(PORT_CLK_SEL(PORT_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2129  	MMIO_D(PORT_CLK_SEL(PORT_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2130  	MMIO_D(PORT_CLK_SEL(PORT_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2131  	MMIO_D(PORT_CLK_SEL(PORT_D), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2132  	MMIO_D(PORT_CLK_SEL(PORT_E), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2133  	MMIO_D(TRANS_CLK_SEL(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2134  	MMIO_D(TRANS_CLK_SEL(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2135  	MMIO_D(TRANS_CLK_SEL(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2136  
e39c5add3 Zhi Wang       2016-09-02  2137  	MMIO_D(HSW_NDE_RSTWRN_OPT, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2138  	MMIO_D(0x46508, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2139  
e39c5add3 Zhi Wang       2016-09-02  2140  	MMIO_D(0x49080, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2141  	MMIO_D(0x49180, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2142  	MMIO_D(0x49280, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2143  
e39c5add3 Zhi Wang       2016-09-02  2144  	MMIO_F(0x49090, 0x14, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2145  	MMIO_F(0x49190, 0x14, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2146  	MMIO_F(0x49290, 0x14, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2147  
e39c5add3 Zhi Wang       2016-09-02  2148  	MMIO_D(GAMMA_MODE(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2149  	MMIO_D(GAMMA_MODE(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2150  	MMIO_D(GAMMA_MODE(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2151  
e39c5add3 Zhi Wang       2016-09-02  2152  	MMIO_D(PIPE_MULT(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2153  	MMIO_D(PIPE_MULT(PIPE_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2154  	MMIO_D(PIPE_MULT(PIPE_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2155  
e39c5add3 Zhi Wang       2016-09-02  2156  	MMIO_D(HSW_TVIDEO_DIP_CTL(TRANSCODER_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2157  	MMIO_D(HSW_TVIDEO_DIP_CTL(TRANSCODER_B), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2158  	MMIO_D(HSW_TVIDEO_DIP_CTL(TRANSCODER_C), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2159  
e39c5add3 Zhi Wang       2016-09-02  2160  	MMIO_DH(SFUSE_STRAP, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2161  	MMIO_D(SBI_ADDR, D_ALL);
04d348ae3 Zhi Wang       2016-04-25  2162  	MMIO_DH(SBI_DATA, D_ALL, sbi_data_mmio_read, NULL);
04d348ae3 Zhi Wang       2016-04-25  2163  	MMIO_DH(SBI_CTL_STAT, D_ALL, NULL, sbi_ctl_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2164  	MMIO_D(PIXCLK_GATE, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2165  
04d348ae3 Zhi Wang       2016-04-25  2166  	MMIO_F(_DPA_AUX_CH_CTL, 6 * 4, 0, 0, 0, D_ALL, NULL,
04d348ae3 Zhi Wang       2016-04-25  2167  		dp_aux_ch_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2168  
04d348ae3 Zhi Wang       2016-04-25  2169  	MMIO_DH(DDI_BUF_CTL(PORT_A), D_ALL, NULL, ddi_buf_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2170  	MMIO_DH(DDI_BUF_CTL(PORT_B), D_ALL, NULL, ddi_buf_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2171  	MMIO_DH(DDI_BUF_CTL(PORT_C), D_ALL, NULL, ddi_buf_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2172  	MMIO_DH(DDI_BUF_CTL(PORT_D), D_ALL, NULL, ddi_buf_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2173  	MMIO_DH(DDI_BUF_CTL(PORT_E), D_ALL, NULL, ddi_buf_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2174  
04d348ae3 Zhi Wang       2016-04-25  2175  	MMIO_DH(DP_TP_CTL(PORT_A), D_ALL, NULL, dp_tp_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2176  	MMIO_DH(DP_TP_CTL(PORT_B), D_ALL, NULL, dp_tp_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2177  	MMIO_DH(DP_TP_CTL(PORT_C), D_ALL, NULL, dp_tp_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2178  	MMIO_DH(DP_TP_CTL(PORT_D), D_ALL, NULL, dp_tp_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2179  	MMIO_DH(DP_TP_CTL(PORT_E), D_ALL, NULL, dp_tp_ctl_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2180  
04d348ae3 Zhi Wang       2016-04-25  2181  	MMIO_DH(DP_TP_STATUS(PORT_A), D_ALL, NULL, dp_tp_status_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2182  	MMIO_DH(DP_TP_STATUS(PORT_B), D_ALL, NULL, dp_tp_status_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2183  	MMIO_DH(DP_TP_STATUS(PORT_C), D_ALL, NULL, dp_tp_status_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2184  	MMIO_DH(DP_TP_STATUS(PORT_D), D_ALL, NULL, dp_tp_status_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2185  	MMIO_DH(DP_TP_STATUS(PORT_E), D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2186  
e39c5add3 Zhi Wang       2016-09-02  2187  	MMIO_F(_DDI_BUF_TRANS_A, 0x50, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2188  	MMIO_F(0x64e60, 0x50, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2189  	MMIO_F(0x64eC0, 0x50, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2190  	MMIO_F(0x64f20, 0x50, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2191  	MMIO_F(0x64f80, 0x50, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2192  
e39c5add3 Zhi Wang       2016-09-02  2193  	MMIO_D(HSW_AUD_CFG(PIPE_A), D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2194  	MMIO_D(HSW_AUD_PIN_ELD_CP_VLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2195  
e39c5add3 Zhi Wang       2016-09-02  2196  	MMIO_DH(_TRANS_DDI_FUNC_CTL_A, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2197  	MMIO_DH(_TRANS_DDI_FUNC_CTL_B, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2198  	MMIO_DH(_TRANS_DDI_FUNC_CTL_C, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2199  	MMIO_DH(_TRANS_DDI_FUNC_CTL_EDP, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2200  
e39c5add3 Zhi Wang       2016-09-02  2201  	MMIO_D(_TRANSA_MSA_MISC, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2202  	MMIO_D(_TRANSB_MSA_MISC, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2203  	MMIO_D(_TRANSC_MSA_MISC, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2204  	MMIO_D(_TRANS_EDP_MSA_MISC, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2205  
e39c5add3 Zhi Wang       2016-09-02  2206  	MMIO_DH(FORCEWAKE, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2207  	MMIO_D(FORCEWAKE_ACK, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2208  	MMIO_D(GEN6_GT_CORE_STATUS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2209  	MMIO_D(GEN6_GT_THREAD_STATUS_REG, D_ALL);
0aa5277c3 Zhao Yan       2017-02-28  2210  	MMIO_DFH(GTFIFODBG, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2211  	MMIO_DFH(GTFIFOCTL, D_ALL, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2212  	MMIO_DH(FORCEWAKE_MT, D_PRE_SKL, NULL, mul_force_wake_write);
a1dcba905 fred gao       2017-05-25  2213  	MMIO_DH(FORCEWAKE_ACK_HSW, D_BDW, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2214  	MMIO_D(ECOBUS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2215  	MMIO_DH(GEN6_RC_CONTROL, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2216  	MMIO_DH(GEN6_RC_STATE, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2217  	MMIO_D(GEN6_RPNSWREQ, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2218  	MMIO_D(GEN6_RC_VIDEO_FREQ, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2219  	MMIO_D(GEN6_RP_DOWN_TIMEOUT, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2220  	MMIO_D(GEN6_RP_INTERRUPT_LIMITS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2221  	MMIO_D(GEN6_RPSTAT1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2222  	MMIO_D(GEN6_RP_CONTROL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2223  	MMIO_D(GEN6_RP_UP_THRESHOLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2224  	MMIO_D(GEN6_RP_DOWN_THRESHOLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2225  	MMIO_D(GEN6_RP_CUR_UP_EI, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2226  	MMIO_D(GEN6_RP_CUR_UP, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2227  	MMIO_D(GEN6_RP_PREV_UP, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2228  	MMIO_D(GEN6_RP_CUR_DOWN_EI, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2229  	MMIO_D(GEN6_RP_CUR_DOWN, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2230  	MMIO_D(GEN6_RP_PREV_DOWN, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2231  	MMIO_D(GEN6_RP_UP_EI, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2232  	MMIO_D(GEN6_RP_DOWN_EI, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2233  	MMIO_D(GEN6_RP_IDLE_HYSTERSIS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2234  	MMIO_D(GEN6_RC1_WAKE_RATE_LIMIT, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2235  	MMIO_D(GEN6_RC6_WAKE_RATE_LIMIT, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2236  	MMIO_D(GEN6_RC6pp_WAKE_RATE_LIMIT, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2237  	MMIO_D(GEN6_RC_EVALUATION_INTERVAL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2238  	MMIO_D(GEN6_RC_IDLE_HYSTERSIS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2239  	MMIO_D(GEN6_RC_SLEEP, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2240  	MMIO_D(GEN6_RC1e_THRESHOLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2241  	MMIO_D(GEN6_RC6_THRESHOLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2242  	MMIO_D(GEN6_RC6p_THRESHOLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2243  	MMIO_D(GEN6_RC6pp_THRESHOLD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2244  	MMIO_D(GEN6_PMINTRMSK, D_ALL);
9c3a16c88 Imre Deak      2017-08-14  2245  	/*
9c3a16c88 Imre Deak      2017-08-14  2246  	 * Use an arbitrary power well controlled by the PWR_WELL_CTL
9c3a16c88 Imre Deak      2017-08-14  2247  	 * register.
9c3a16c88 Imre Deak      2017-08-14  2248  	 */
9c3a16c88 Imre Deak      2017-08-14  2249  	MMIO_DH(HSW_PWR_WELL_CTL_BIOS(HSW_DISP_PW_GLOBAL), D_BDW, NULL,
9c3a16c88 Imre Deak      2017-08-14  2250  		power_well_ctl_mmio_write);
9c3a16c88 Imre Deak      2017-08-14  2251  	MMIO_DH(HSW_PWR_WELL_CTL_DRIVER(HSW_DISP_PW_GLOBAL), D_BDW, NULL,
9c3a16c88 Imre Deak      2017-08-14  2252  		power_well_ctl_mmio_write);
9c3a16c88 Imre Deak      2017-08-14  2253  	MMIO_DH(HSW_PWR_WELL_CTL_KVMR, D_BDW, NULL, power_well_ctl_mmio_write);
9c3a16c88 Imre Deak      2017-08-14  2254  	MMIO_DH(HSW_PWR_WELL_CTL_DEBUG(HSW_DISP_PW_GLOBAL), D_BDW, NULL,
9c3a16c88 Imre Deak      2017-08-14  2255  		power_well_ctl_mmio_write);
a1dcba905 fred gao       2017-05-25  2256  	MMIO_DH(HSW_PWR_WELL_CTL5, D_BDW, NULL, power_well_ctl_mmio_write);
a1dcba905 fred gao       2017-05-25  2257  	MMIO_DH(HSW_PWR_WELL_CTL6, D_BDW, NULL, power_well_ctl_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2258  
e39c5add3 Zhi Wang       2016-09-02  2259  	MMIO_D(RSTDBYCTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2260  
e39c5add3 Zhi Wang       2016-09-02  2261  	MMIO_DH(GEN6_GDRST, D_ALL, NULL, gdrst_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2262  	MMIO_F(FENCE_REG_GEN6_LO(0), 0x80, 0, 0, 0, D_ALL, fence_mmio_read, fence_mmio_write);
04d348ae3 Zhi Wang       2016-04-25  2263  	MMIO_DH(CPU_VGACNTRL, D_ALL, NULL, vga_control_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2264  
e39c5add3 Zhi Wang       2016-09-02  2265  	MMIO_D(TILECTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2266  
e39c5add3 Zhi Wang       2016-09-02  2267  	MMIO_D(GEN6_UCGCTL1, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2268  	MMIO_D(GEN6_UCGCTL2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2269  
e39c5add3 Zhi Wang       2016-09-02  2270  	MMIO_F(0x4f000, 0x90, 0, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2271  
e39c5add3 Zhi Wang       2016-09-02  2272  	MMIO_D(GEN6_PCODE_DATA, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2273  	MMIO_D(0x13812c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2274  	MMIO_DH(GEN7_ERR_INT, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2275  	MMIO_D(HSW_EDRAM_CAP, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2276  	MMIO_D(HSW_IDICR, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2277  	MMIO_DH(GFX_FLSH_CNTL_GEN6, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2278  
e39c5add3 Zhi Wang       2016-09-02  2279  	MMIO_D(0x3c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2280  	MMIO_D(0x860, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2281  	MMIO_D(ECOSKPD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2282  	MMIO_D(0x121d0, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2283  	MMIO_D(GEN6_BLITTER_ECOSKPD, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2284  	MMIO_D(0x41d0, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2285  	MMIO_D(GAC_ECO_BITS, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2286  	MMIO_D(0x6200, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2287  	MMIO_D(0x6204, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2288  	MMIO_D(0x6208, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2289  	MMIO_D(0x7118, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2290  	MMIO_D(0x7180, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2291  	MMIO_D(0x7408, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2292  	MMIO_D(0x7c00, D_ALL);
975629c3f Pei Zhang      2017-03-20  2293  	MMIO_DH(GEN6_MBCTL, D_ALL, NULL, mbctl_write);
e39c5add3 Zhi Wang       2016-09-02  2294  	MMIO_D(0x911c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2295  	MMIO_D(0x9120, D_ALL);
a045fba47 Ping Gao       2016-11-14  2296  	MMIO_DFH(GEN7_UCGCTL4, D_ALL, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2297  
e39c5add3 Zhi Wang       2016-09-02  2298  	MMIO_D(GAB_CTL, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2299  	MMIO_D(0x48800, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2300  	MMIO_D(0xce044, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2301  	MMIO_D(0xe6500, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2302  	MMIO_D(0xe6504, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2303  	MMIO_D(0xe6600, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2304  	MMIO_D(0xe6604, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2305  	MMIO_D(0xe6700, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2306  	MMIO_D(0xe6704, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2307  	MMIO_D(0xe6800, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2308  	MMIO_D(0xe6804, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2309  	MMIO_D(PCH_GMBUS4, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2310  	MMIO_D(PCH_GMBUS5, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2311  
e39c5add3 Zhi Wang       2016-09-02  2312  	MMIO_D(0x902c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2313  	MMIO_D(0xec008, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2314  	MMIO_D(0xec00c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2315  	MMIO_D(0xec008 + 0x18, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2316  	MMIO_D(0xec00c + 0x18, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2317  	MMIO_D(0xec008 + 0x18 * 2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2318  	MMIO_D(0xec00c + 0x18 * 2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2319  	MMIO_D(0xec008 + 0x18 * 3, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2320  	MMIO_D(0xec00c + 0x18 * 3, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2321  	MMIO_D(0xec408, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2322  	MMIO_D(0xec40c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2323  	MMIO_D(0xec408 + 0x18, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2324  	MMIO_D(0xec40c + 0x18, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2325  	MMIO_D(0xec408 + 0x18 * 2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2326  	MMIO_D(0xec40c + 0x18 * 2, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2327  	MMIO_D(0xec408 + 0x18 * 3, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2328  	MMIO_D(0xec40c + 0x18 * 3, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2329  	MMIO_D(0xfc810, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2330  	MMIO_D(0xfc81c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2331  	MMIO_D(0xfc828, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2332  	MMIO_D(0xfc834, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2333  	MMIO_D(0xfcc00, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2334  	MMIO_D(0xfcc0c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2335  	MMIO_D(0xfcc18, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2336  	MMIO_D(0xfcc24, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2337  	MMIO_D(0xfd000, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2338  	MMIO_D(0xfd00c, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2339  	MMIO_D(0xfd018, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2340  	MMIO_D(0xfd024, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2341  	MMIO_D(0xfd034, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2342  
e39c5add3 Zhi Wang       2016-09-02  2343  	MMIO_DH(FPGA_DBG, D_ALL, NULL, fpga_dbg_mmio_write);
e39c5add3 Zhi Wang       2016-09-02  2344  	MMIO_D(0x2054, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2345  	MMIO_D(0x12054, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2346  	MMIO_D(0x22054, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2347  	MMIO_D(0x1a054, D_ALL);
e39c5add3 Zhi Wang       2016-09-02  2348  
e39c5add3 Zhi Wang       2016-09-02  2349  	MMIO_D(0x44070, D_ALL);
a1dcba905 fred gao       2017-05-25  2350  	MMIO_DFH(0x215c, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2351  	MMIO_DFH(0x2178, D_ALL, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2352  	MMIO_DFH(0x217c, D_ALL, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2353  	MMIO_DFH(0x12178, D_ALL, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2354  	MMIO_DFH(0x1217c, D_ALL, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2355  
a1dcba905 fred gao       2017-05-25  2356  	MMIO_F(0x2290, 8, F_CMD_ACCESS, 0, 0, D_BDW_PLUS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2357  	MMIO_D(0x2b00, D_BDW_PLUS);
e39c5add3 Zhi Wang       2016-09-02  2358  	MMIO_D(0x2360, D_BDW_PLUS);
0aa5277c3 Zhao Yan       2017-02-28  2359  	MMIO_F(0x5200, 32, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2360  	MMIO_F(0x5240, 32, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2361  	MMIO_F(0x5280, 16, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2362  
e39c5add3 Zhi Wang       2016-09-02  2363  	MMIO_DFH(0x1c17c, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2364  	MMIO_DFH(0x1c178, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2365  	MMIO_DFH(BCS_SWCTRL, D_ALL, F_CMD_ACCESS, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2366  
0aa5277c3 Zhao Yan       2017-02-28  2367  	MMIO_F(HS_INVOCATION_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2368  	MMIO_F(DS_INVOCATION_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2369  	MMIO_F(IA_VERTICES_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2370  	MMIO_F(IA_PRIMITIVES_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2371  	MMIO_F(VS_INVOCATION_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2372  	MMIO_F(GS_INVOCATION_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2373  	MMIO_F(GS_PRIMITIVES_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2374  	MMIO_F(CL_INVOCATION_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2375  	MMIO_F(CL_PRIMITIVES_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2376  	MMIO_F(PS_INVOCATION_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
0aa5277c3 Zhao Yan       2017-02-28  2377  	MMIO_F(PS_DEPTH_COUNT, 8, F_CMD_ACCESS, 0, 0, D_ALL, NULL, NULL);
178657139 Zhi Wang       2016-05-01  2378  	MMIO_DH(0x4260, D_BDW_PLUS, NULL, gvt_reg_tlb_control_handler);
178657139 Zhi Wang       2016-05-01  2379  	MMIO_DH(0x4264, D_BDW_PLUS, NULL, gvt_reg_tlb_control_handler);
178657139 Zhi Wang       2016-05-01  2380  	MMIO_DH(0x4268, D_BDW_PLUS, NULL, gvt_reg_tlb_control_handler);
178657139 Zhi Wang       2016-05-01  2381  	MMIO_DH(0x426c, D_BDW_PLUS, NULL, gvt_reg_tlb_control_handler);
178657139 Zhi Wang       2016-05-01  2382  	MMIO_DH(0x4270, D_BDW_PLUS, NULL, gvt_reg_tlb_control_handler);
e39c5add3 Zhi Wang       2016-09-02  2383  	MMIO_DFH(0x4094, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
e39c5add3 Zhi Wang       2016-09-02  2384  
9112caafd Zhao Yan       2017-02-28  2385  	MMIO_DFH(ARB_MODE, D_ALL, F_MODE_MASK | F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2386  	MMIO_RING_GM_RDR(RING_BBADDR, D_ALL, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2387  	MMIO_DFH(0x2220, D_ALL, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2388  	MMIO_DFH(0x12220, D_ALL, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2389  	MMIO_DFH(0x22220, D_ALL, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2390  	MMIO_RING_DFH(RING_SYNC_1, D_ALL, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2391  	MMIO_RING_DFH(RING_SYNC_0, D_ALL, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2392  	MMIO_DFH(0x22178, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2393  	MMIO_DFH(0x1a178, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2394  	MMIO_DFH(0x1a17c, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
9112caafd Zhao Yan       2017-02-28  2395  	MMIO_DFH(0x2217c, D_BDW_PLUS, F_CMD_ACCESS, NULL, NULL);
12d14cc43 Zhi Wang       2016-08-30  2396  	return 0;
12d14cc43 Zhi Wang       2016-08-30 @2397  }
12d14cc43 Zhi Wang       2016-08-30  2398  

:::::: The code at line 2397 was first introduced by commit
:::::: 12d14cc43b34706283246917329b2182163ba9aa drm/i915/gvt: Introduce a framework for tracking HW registers.

:::::: TO: Zhi Wang <zhi.a.wang@intel.com>
:::::: CC: Zhenyu Wang <zhenyuw@linux.intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2oS5YaxWCcQjTEyO
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
jwEA

--2oS5YaxWCcQjTEyO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
