Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BD5456B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:10:23 -0400 (EDT)
Date: Wed, 18 Aug 2010 23:07:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] Export mlock information via smaps
Message-ID: <20100818150727.GA10490@localhost>
References: <201008171039.31070.knikanth@suse.de>
 <1282062336.10679.226.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282062336.10679.226.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Nikanth Karthikesan <knikanth@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Nikanth,

On Tue, Aug 17, 2010 at 11:25:36AM -0500, Matt Mackall wrote:
> On Tue, 2010-08-17 at 10:39 +0530, Nikanth Karthikesan wrote:
> > Currently there is no way to find whether a process has locked its pages in
> > memory or not. And which of the memory regions are locked in memory.

FYI, Documentation/vm/page-types.c can report mlocked pages.
Try this:

        # usemem 1m --mlock --sleep 10000&

        # page-types -r -p `pidof usemem` -l
        voffset offset  len     flags
        400     32826   1       __RU_lA____M____________d_________
        401     2eba2   1       ___U_lA____M____________d_________
        402     36ad8   1       ___U_lA____M____________d_________
        603     37025   1       ___U_lA____Ma_b___________________
        7f2b9d38d       1390b5  1       __RU_lA____M____________d_________
        7f2b9d38e       1390ba  3       __RU_lA____M____________d_________
        7f2b9d391       139116  1       __RU_lA____M____________d_________
        7f2b9d392       1390d0  5       __RU_lA____M____________d_________
        7f2b9d397       1390d9  16      __RU_lA____M____________d_________
        7f2b9d3be       139109  1       __RU_lA____M____________d_________
        7f2b9d3bf       139108  1       __RU_lA____M____________d_________
        7f2b9d3c2       139105  1       __RU_lA____M____________d_________
        7f2b9d3c3       139104  1       __RU_lA____M____________d_________
        7f2b9d3c4       139103  1       __RU_lA____M____________d_________
        7f2b9d408       1391b3  3       __RU_lA____M____________d_________
        7f2b9d412       1391bd  2       __RU_lA____M____________d_________
        7f2b9d42d       1391d3  1       __RU_lA____M____________d_________
        7f2b9d42f       1391d5  1       __RU_lA____M____________d_________
        7f2b9d435       1391db  2       __RU_lA____M____________d_________
        7f2b9d454       13918e  2       __RU_lA____M____________d_________
        7f2b9d458       139192  1       __RU_lA____M____________d_________
        7f2b9d45b       139195  1       __RU_lA____M____________d_________
        7f2b9d468       1391a2  2       __RU_lA____M____________d_________
        7f2b9d492       139176  1       __RU_lA____M____________d_________
        7f2b9d49e       139182  2       __RU_lA____M____________d_________
        7f2b9d4aa       13914e  1       __RU_lA____M____________d_________
        7f2b9d4ad       139151  2       __RU_lA____M____________d_________
        7f2b9d4b1       139156  1       __RU_lA____M____________d_________
        7f2b9d4b3       139158  2       __RU_lA____M____________d_________
        7f2b9d6e4       2dfb5   1       ___U_lA____Ma_b___________________
        7f2b9d6e5       81643   1       ___U_lA____Ma_b___________________
        7f2b9d6e6       33d35   1       ___U_lA____Ma_b___________________
        7f2b9d6e7       39ee8   1       ___U_lA____Ma_b___________________
        7f2b9d6e8       41238   1       ___U_lA____Ma_b___________________
        7f2b9d6e9       2fe04   1       ___U_lA____Ma_b___________________
        7f2b9d6ea       3010d   1       ___U_lA____Ma_b___________________
        7f2b9d6eb       2f916   1       ___U_lA____Ma_b___________________
        7f2b9d6ed       2ed81   1       ___U_lA____Ma_b___________________
        7f2b9d6ee       138c62  1       __RU_lA____M____________d_________
        7f2b9d6ef       138dac  1       __RU_lA____M____________d_________
        7f2b9d6f0       138ddf  1       __RU_lA____M____________d_________
        7f2b9d6f1       138c68  1       __RU_lA____M____________d_________
        7f2b9d6f2       138e08  1       __RU_lA____M____________d_________
        7f2b9d6f3       138e23  1       __RU_lA____M____________d_________
        7f2b9d6fc       138e1b  1       __RU_lA____M____________d_________
        7f2b9d6fd       138e1a  1       __RU_lA____M____________d_________
        7f2b9d6fe       138e19  1       __RU_lA____M____________d_________
        7f2b9d904       2f322   1       ___U_lA____Ma_b___________________
        7f2b9d905       2ede6   1       ___U_lA____Ma_b___________________
        7f2b9d909       2ca5a   1       ___U_lA____Ma_b___________________
        7f2b9d90a       139023  4       __RU_lA____M____________d_________
        7f2b9d90e       139048  a       __RU_lA____M____________d_________
        7f2b9d918       13902d  3       __RU_lA____M____________d_________
        7f2b9d91d       139032  3       __RU_lA____M____________d_________
        7f2b9d920       13903e  3       __RU_lA____M____________d_________
        7f2b9d925       139043  1       __RU_lA____M____________d_________
        7f2b9da01       38582   1       __RU_l_____Ma_b___u____m__________
        7f2b9da02       32d75   1       __RU_l_____Ma_b___u____m__________
        7f2b9da03       2726e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da04       33279   1       __RU_l_____Ma_b___u____m__________
        7f2b9da05       2d826   1       __RU_l_____Ma_b___u____m__________
        7f2b9da06       318e9   1       __RU_l_____Ma_b___u____m__________
        7f2b9da07       36e83   1       __RU_l_____Ma_b___u____m__________
        7f2b9da08       467f1   1       __RU_l_____Ma_b___u____m__________
        7f2b9da09       31417   1       __RU_l_____Ma_b___u____m__________
        7f2b9da0a       38c68   1       __RU_l_____Ma_b___u____m__________
        7f2b9da0b       32cf4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da0c       2e51e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da0d       2726f   1       __RU_l_____Ma_b___u____m__________
        7f2b9da0e       37ee5   1       __RU_l_____Ma_b___u____m__________
        7f2b9da0f       30461   1       __RU_l_____Ma_b___u____m__________
        7f2b9da10       2c7a5   1       __RU_l_____Ma_b___u____m__________
        7f2b9da11       3d2c7   1       __RU_l_____Ma_b___u____m__________
        7f2b9da12       33ede   1       __RU_l_____Ma_b___u____m__________
        7f2b9da13       5cd3e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da14       373f4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da15       3163a   1       __RU_l_____Ma_b___u____m__________
        7f2b9da16       2eba3   1       __RU_l_____Ma_b___u____m__________
        7f2b9da17       5e1c4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da18       3e761   1       __RU_l_____Ma_b___u____m__________
        7f2b9da19       4b6c5   1       __RU_l_____Ma_b___u____m__________
        7f2b9da1a       2efd1   1       __RU_l_____Ma_b___u____m__________
        7f2b9da1b       32b62   1       __RU_l_____Ma_b___u____m__________
        7f2b9da1c       3851a   1       __RU_l_____Ma_b___u____m__________
        7f2b9da1d       2f33e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da1e       3e2e4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da1f       31e5c   1       __RU_l_____Ma_b___u____m__________
        7f2b9da20       2f33d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da21       5ddc4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da22       302e0   1       __RU_l_____Ma_b___u____m__________
        7f2b9da23       2ea24   1       __RU_l_____Ma_b___u____m__________
        7f2b9da24       50972   1       __RU_l_____Ma_b___u____m__________
        7f2b9da25       38935   1       __RU_l_____Ma_b___u____m__________
        7f2b9da26       35c30   1       __RU_l_____Ma_b___u____m__________
        7f2b9da27       2e51d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da28       2dca2   1       __RU_l_____Ma_b___u____m__________
        7f2b9da29       4235d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da2a       368a4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da2b       2d3be   1       __RU_l_____Ma_b___u____m__________
        7f2b9da2c       3ab26   1       __RU_l_____Ma_b___u____m__________
        7f2b9da2d       2c60d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da2e       396b0   1       __RU_l_____Ma_b___u____m__________
        7f2b9da2f       38326   1       __RU_l_____Ma_b___u____m__________
        7f2b9da30       36fc1   1       __RU_l_____Ma_b___u____m__________
        7f2b9da31       34a40   1       __RU_l_____Ma_b___u____m__________
        7f2b9da32       363f6   1       __RU_l_____Ma_b___u____m__________
        7f2b9da33       324c5   1       __RU_l_____Ma_b___u____m__________
        7f2b9da34       31ebe   1       __RU_l_____Ma_b___u____m__________
        7f2b9da35       3fb0b   1       __RU_l_____Ma_b___u____m__________
        7f2b9da36       3bac6   1       __RU_l_____Ma_b___u____m__________
        7f2b9da37       360b3   1       __RU_l_____Ma_b___u____m__________
        7f2b9da38       2c727   1       __RU_l_____Ma_b___u____m__________
        7f2b9da39       33edc   1       __RU_l_____Ma_b___u____m__________
        7f2b9da3a       57592   1       __RU_l_____Ma_b___u____m__________
        7f2b9da3b       2e9b2   1       __RU_l_____Ma_b___u____m__________
        7f2b9da3c       30587   1       __RU_l_____Ma_b___u____m__________
        7f2b9da3d       3b4bd   1       __RU_l_____Ma_b___u____m__________
        7f2b9da3e       33e09   1       __RU_l_____Ma_b___u____m__________
        7f2b9da3f       2c724   2       __RU_l_____Ma_b___u____m__________
        7f2b9da41       31e5e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da42       3ad93   1       __RU_l_____Ma_b___u____m__________
        7f2b9da43       33449   1       __RU_l_____Ma_b___u____m__________
        7f2b9da44       3180d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da45       5c309   1       __RU_l_____Ma_b___u____m__________
        7f2b9da46       4582e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da47       3114d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da48       2c61b   1       __RU_l_____Ma_b___u____m__________
        7f2b9da49       45a30   1       __RU_l_____Ma_b___u____m__________
        7f2b9da4a       60bfc   1       __RU_l_____Ma_b___u____m__________
        7f2b9da4b       2726c   1       __RU_l_____Ma_b___u____m__________
        7f2b9da4c       39808   1       __RU_l_____Ma_b___u____m__________
        7f2b9da4d       354d5   1       __RU_l_____Ma_b___u____m__________
        7f2b9da4e       2e4c4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da4f       36f94   1       __RU_l_____Ma_b___u____m__________
        7f2b9da50       2f6e1   1       __RU_l_____Ma_b___u____m__________
        7f2b9da51       39028   1       __RU_l_____Ma_b___u____m__________
        7f2b9da52       48553   1       __RU_l_____Ma_b___u____m__________
        7f2b9da53       30ff2   1       __RU_l_____Ma_b___u____m__________
        7f2b9da54       2cb66   1       __RU_l_____Ma_b___u____m__________
        7f2b9da55       2fe05   1       __RU_l_____Ma_b___u____m__________
        7f2b9da56       346d3   1       __RU_l_____Ma_b___u____m__________
        7f2b9da57       2e4c6   1       __RU_l_____Ma_b___u____m__________
        7f2b9da58       3cf94   1       __RU_l_____Ma_b___u____m__________
        7f2b9da59       3b4bc   1       __RU_l_____Ma_b___u____m__________
        7f2b9da5a       3b0b2   1       __RU_l_____Ma_b___u____m__________
        7f2b9da5b       36f9e   1       __RU_l_____Ma_b___u____m__________
        7f2b9da5c       3afc3   1       __RU_l_____Ma_b___u____m__________
        7f2b9da5d       363f7   1       __RU_l_____Ma_b___u____m__________
        7f2b9da5e       2efb6   1       __RU_l_____Ma_b___u____m__________
        7f2b9da5f       2fc04   1       __RU_l_____Ma_b___u____m__________
        7f2b9da60       3e162   1       __RU_l_____Ma_b___u____m__________
        7f2b9da61       34495   1       __RU_l_____Ma_b___u____m__________
        7f2b9da62       2ce82   1       __RU_l_____Ma_b___u____m__________
        7f2b9da63       5cae0   1       __RU_l_____Ma_b___u____m__________
        7f2b9da64       30838   1       __RU_l_____Ma_b___u____m__________
        7f2b9da65       3980a   1       __RU_l_____Ma_b___u____m__________
        7f2b9da66       368a5   1       __RU_l_____Ma_b___u____m__________
        7f2b9da67       53af9   1       __RU_l_____Ma_b___u____m__________
        7f2b9da68       3464a   1       __RU_l_____Ma_b___u____m__________
        7f2b9da69       32a3a   1       __RU_l_____Ma_b___u____m__________
        7f2b9da6a       5423c   1       __RU_l_____Ma_b___u____m__________
        7f2b9da6b       32dd6   1       __RU_l_____Ma_b___u____m__________
        7f2b9da6c       33e08   1       __RU_l_____Ma_b___u____m__________
        7f2b9da6d       35d41   1       __RU_l_____Ma_b___u____m__________
        7f2b9da6e       32d74   1       __RU_l_____Ma_b___u____m__________
        7f2b9da6f       2d827   1       __RU_l_____Ma_b___u____m__________
        7f2b9da70       37c1d   1       __RU_l_____Ma_b___u____m__________
        7f2b9da71       2cf46   1       __RU_l_____Ma_b___u____m__________
        7f2b9da72       59284   1       __RU_l_____Ma_b___u____m__________
        7f2b9da73       31c7f   1       __RU_l_____Ma_b___u____m__________
        7f2b9da74       3eda9   1       __RU_l_____Ma_b___u____m__________
        7f2b9da75       2f33c   1       __RU_l_____Ma_b___u____m__________
        7f2b9da76       54236   1       __RU_l_____Ma_b___u____m__________
        7f2b9da77       2c7a4   1       __RU_l_____Ma_b___u____m__________
        7f2b9da78       3cd04   1       __RU_l_____Ma_b___u____m__________
        7f2b9da79       329cb   1       __RU_l_____Ma_b___u____m__________
        7f2b9da7a       38434   1       __RU_l_____Ma_b___u____m__________
        7f2b9da7b       301eb   1       __RU_l_____Ma_b___u____m__________
        7f2b9da7c       2e472   1       __RU_l_____Ma_b___u____m__________
        7f2b9da7d       440fb   1       __RU_l_____Ma_b___u____m__________
        7f2b9da7e       2f770   1       __RU_l_____Ma_b___u____m__________
        7f2b9da7f       36e28   1       __RU_l_____Ma_b___u____m__________
        7f2b9da80       3036b   1       __RU_l_____Ma_b___u____m__________
        7f2b9da81       36716   1       __RU_l_____Ma_b___u____m__________
        7f2b9da82       38805   1       __RU_l_____Ma_b___u____m__________
        7f2b9da83       32b63   1       __RU_l_____Ma_b___u____m__________
        7f2b9da84       af25c   1       __RU_l_____Ma_b___u____m__________
        7f2b9da85       38581   1       __RU_l_____Ma_b___u____m__________
        7f2b9da86       2ec22   1       __RU_l_____Ma_b___u____m__________
        7f2b9da87       33e0a   2       __RU_l_____Ma_b___u____m__________
        7f2b9da89       2eba0   2       __RU_l_____Ma_b___u____m__________
        7f2b9da8b       3b4be   2       __RU_l_____Ma_b___u____m__________
        7f2b9da8d       31ebc   2       __RU_l_____Ma_b___u____m__________
        7f2b9da8f       2e9de   2       __RU_l_____Ma_b___u____m__________
        7f2b9da91       368a6   2       __RU_l_____Ma_b___u____m__________
        7f2b9da93       2c7a6   2       __RU_l_____Ma_b___u____m__________
        7f2b9da95       302a4   2       __RU_l_____Ma_b___u____m__________
        7f2b9da97       415fa   2       __RU_l_____Ma_b___u____m__________
        7f2b9da99       34648   2       __RU_l_____Ma_b___u____m__________
        7f2b9da9b       2fe06   2       __RU_l_____Ma_b___u____m__________
        7f2b9da9d       32cf6   2       __RU_l_____Ma_b___u____m__________
        7f2b9da9f       35b9a   2       __RU_l_____Ma_b___u____m__________
        7f2b9daa1       2fad8   4       __RU_l_____Ma_b___u____m__________
        7f2b9daa5       30bc0   4       __RU_l_____Ma_b___u____m__________
        7f2b9daa9       2f064   4       __RU_l_____Ma_b___u____m__________
        7f2b9daad       30cac   4       __RU_l_____Ma_b___u____m__________
        7f2b9dab1       2f330   4       __RU_l_____Ma_b___u____m__________
        7f2b9dab5       36580   4       __RU_l_____Ma_b___u____m__________
        7f2b9dab9       2f0c0   4       __RU_l_____Ma_b___u____m__________
        7f2b9dabd       32958   4       __RU_l_____Ma_b___u____m__________
        7f2b9dac1       2f1c0   4       __RU_l_____Ma_b___u____m__________
        7f2b9dac5       2d6b4   4       __RU_l_____Ma_b___u____m__________
        7f2b9dac9       311c8   4       __RU_l_____Ma_b___u____m__________
        7f2b9dacd       3342c   4       __RU_l_____Ma_b___u____m__________
        7f2b9dad1       33f98   4       __RU_l_____Ma_b___u____m__________
        7f2b9dad5       346ac   4       __RU_l_____Ma_b___u____m__________
        7f2b9dad9       328bc   4       __RU_l_____Ma_b___u____m__________
        7f2b9dadd       39190   4       __RU_l_____Ma_b___u____m__________
        7f2b9dae1       2cd90   4       __RU_l_____Ma_b___u____m__________
        7f2b9dae5       35b84   4       __RU_l_____Ma_b___u____m__________
        7f2b9dae9       304ac   4       __RU_l_____Ma_b___u____m__________
        7f2b9daed       3b0fc   4       __RU_l_____Ma_b___u____m__________
        7f2b9daf1       31214   4       __RU_l_____Ma_b___u____m__________
        7f2b9daf5       34b28   4       __RU_l_____Ma_b___u____m__________
        7f2b9daf9       34e28   4       __RU_l_____Ma_b___u____m__________
        7f2b9dafd       2e3b4   4       __RU_l_____Ma_b___u____m__________
        7f2b9db01       35b98   1       ___U_lA____Ma_b___________________
        7f2b9db02       36f9f   1       ___U_lA____Ma_b___________________
        7f2b9db03       36cb5   1       ___U_lA____Ma_b___________________
        7f2b9db25       39809   1       ___U_lA____Ma_b___________________
        7f2b9db26       34497   1       ___U_lA____Ma_b___________________
        7f2b9db27       31ebf   1       ___U_lA____Ma_b___________________
        7f2b9db28       2ca5b   1       ___U_lA____Ma_b___________________
        7f2b9db29       334ab   1       ___U_lA____Ma_b___________________
        7fff4dcd0       2e53e   1       ___U_lA____Ma_b___________________
        7fff4dcd1       3b1d0   1       __RU_lA____Ma_b___________________
        7fff4ddd6       139f2a  1       __R________M______________________


                     flags      page-count       MB  symbolic-flags                     long-symbolic-flags
        0x0000000000000804               1        0  __R________M______________________ referenced,mmap
        0x0000000400000868               2        0  ___U_lA____M____________d_________ uptodate,lru,active,mmap,mappedtodisk
        0x000000040000086c              95        0  __RU_lA____M____________d_________ referenced,uptodate,lru,active,mmap,mappedtodisk
        0x000000020004582c             256        1  __RU_l_____Ma_b___u____m__________ referenced,uptodate,lru,mmap,anonymous,swapbacked,unevictable,mlocked
        0x0000000000005868              22        0  ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked
        0x000000000000586c               1        0  __RU_lA____Ma_b___________________ referenced,uptodate,lru,active,mmap,anonymous,swapbacked
                     total             377        1

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
