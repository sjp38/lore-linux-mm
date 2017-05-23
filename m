Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E29B6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 02:41:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h76so111771691pfh.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 23:41:37 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 33si20677594ple.43.2017.05.22.23.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 23:41:36 -0700 (PDT)
Date: Tue, 23 May 2017 14:41:07 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
Message-ID: <201705231438.fTyMJFPk%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
In-Reply-To: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Anshuman,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.12-rc2 next-20170522]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Anshuman-Khandual/mm-Define-KB-MB-GB-TB-in-core-VM/20170523-141359
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

>> arch/x86/kernel/cpu/intel_cacheinfo.c:34:0: warning: "MB" redefined
    #define MB(x) ((x) * 1024)
    
   In file included from arch/x86/include/asm/pci.h:4:0,
                    from include/linux/pci.h:1618,
                    from arch/x86/kernel/cpu/intel_cacheinfo.c:16:
   include/linux/mm.h:2553:0: note: this is the location of the previous definition
    #define MB (1UL << 20)
    

vim +/MB +34 arch/x86/kernel/cpu/intel_cacheinfo.c

cd4d09ec arch/x86/kernel/cpu/intel_cacheinfo.c  Borislav Petkov  2016-01-26  18  #include <asm/cpufeature.h>
23ac4ae8 arch/x86/kernel/cpu/intel_cacheinfo.c  Andreas Herrmann 2010-09-17  19  #include <asm/amd_nb.h>
dcf39daf arch/x86/kernel/cpu/intel_cacheinfo.c  Borislav Petkov  2010-01-22  20  #include <asm/smp.h>
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  21  
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  22  #define LVL_1_INST	1
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  23  #define LVL_1_DATA	2
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  24  #define LVL_2		3
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  25  #define LVL_3		4
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  26  #define LVL_TRACE	5
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  27  
8bdbd962 arch/x86/kernel/cpu/intel_cacheinfo.c  Alan Cox         2009-07-04  28  struct _cache_table {
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  29  	unsigned char descriptor;
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  30  	char cache_type;
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  31  	short size;
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  32  };
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  33  
2ca49b2f arch/x86/kernel/cpu/intel_cacheinfo.c  Dave Jones       2010-01-04 @34  #define MB(x)	((x) * 1024)
2ca49b2f arch/x86/kernel/cpu/intel_cacheinfo.c  Dave Jones       2010-01-04  35  
8bdbd962 arch/x86/kernel/cpu/intel_cacheinfo.c  Alan Cox         2009-07-04  36  /* All the cache descriptor types we care about (no TLB or
8bdbd962 arch/x86/kernel/cpu/intel_cacheinfo.c  Alan Cox         2009-07-04  37     trace cache entries) */
8bdbd962 arch/x86/kernel/cpu/intel_cacheinfo.c  Alan Cox         2009-07-04  38  
148f9bb8 arch/x86/kernel/cpu/intel_cacheinfo.c  Paul Gortmaker   2013-06-18  39  static const struct _cache_table cache_table[] =
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  40  {
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  41  	{ 0x06, LVL_1_INST, 8 },	/* 4-way set assoc, 32 byte line size */
^1da177e arch/i386/kernel/cpu/intel_cacheinfo.c Linus Torvalds   2005-04-16  42  	{ 0x08, LVL_1_INST, 16 },	/* 4-way set assoc, 32 byte line size */

:::::: The code at line 34 was first introduced by commit
:::::: 2ca49b2fcf5813571663c3c4c894b78148c43690 x86: Macroise x86 cache descriptors

:::::: TO: Dave Jones <davej@redhat.com>
:::::: CC: Ingo Molnar <mingo@elte.hu>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--k1lZvvs/B4yU6o8G
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICEDYI1kAAy5jb25maWcAjFxbc9u4kn4/v4I1sw8zVZvEt3g8teUHCAQljAmCIUhJ9gtL
kZlEFVvy6jKT/PvtBijx1tDsqTrnxOjGvS9fN5r69T+/Buyw37wu9qvl4uXlZ/C1Wlfbxb56
Dr6sXqr/CUIdJDoPRCjz98Acr9aHHx9W13e3wc37y6v3F++2y6vgodquq5eAb9ZfVl8P0H21
Wf/nV2DnOonkuLy9Gck8WO2C9WYf7Kr9f+r2+d1teX11/7P1d/OHTEyeFTyXOilDwXUosoao
izwt8jLSmWL5/S/Vy5frq3e4rF+OHCzjE+gXuT/vf1lsl98+/Li7/bC0q9zZTZTP1Rf396lf
rPlDKNLSFGmqs7yZ0uSMP+QZ42JIU6po/rAzK8XSMkvCEnZuSiWT+7tzdDa/v7ylGbhWKcv/
dZwOW2e4RIiwNOMyVKyMRTLOJ81axyIRmeSlNAzpQ8JkJuR4kvd3xx7LCZuKMuVlFPKGms2M
UOWcT8YsDEsWj3Um84kajstZLEcZywXcUcwee+NPmCl5WpQZ0OYUjfGJKGOZwF3IJ9Fw2EUZ
kRdpmYrMjsEy0dqXPYwjSagR/BXJzOQlnxTJg4cvZWNBs7kVyZHIEmYlNdXGyFEseiymMKmA
W/KQZyzJy0kBs6QK7moCa6Y47OGx2HLm8Wgwh5VKU+o0lwqOJQQdgjOSydjHGYpRMbbbYzEI
fkcTQTPLmD09lmPj616kmR6JFjmS81KwLH6Ev0slWveejnMG+wYBnIrY3F8d208aCrdpQJM/
vKw+f3jdPB9eqt2H/yoSpgRKgWBGfHjfU1WZfSpnOmtdx6iQcQibF6WYu/lMR0/zCQgDHkuk
4X/KnBnsbE3V2Bq+FzRPhzdoOY6Y6QeRlLAdo9K2cZJ5KZIpHAiuXMn8/vq0J57BLVuFlHDT
v/zSGMK6rcyFoewhXAGLpyIzIEmdfm1CyYpcE52t6D+AIIq4HD/JtKcUNWUElCuaFD+1DUCb
Mn/y9dA+wg0QTstvraq98D7dru0cA66Q2Hl7lcMu+vyIN8SAIJSsiEEjtclRAu9/+W29WVe/
t27EPJqpTDk5trt/EH+dPZYsB78xIfmiCUvCWJC0wggwkL5rtmrICnDKsA4QjfgoxaASwe7w
efdzt69eGyk+mXnQGKuzhAcAkpnoWUvGoQUcLAc74vSmY0hMyjIjkKlp4+g8jS6gDxisnE9C
3Tc9bZaQ5YzuPAXvEKJziBna3EceEyu2ej5tDqDvYXA8sDZJbs4S0amWLPyrMDnBpzSaOVzL
8Yjz1Wu13VGnPHlCjyF1KHlbEhONFOm7aUsmKRPwvGD8jN1pZto8Dl2lxYd8sfse7GFJwWL9
HOz2i/0uWCyXm8N6v1p/bdaWS/7g3CHnukhyd5enqfCu7Xk25MF0GS8CM9w18D6WQGsPB3+C
BYbDoKyccczt7qbXHw2zwVHIc8HRAY3FMdpTpRNiDmRxuEeM+ci6lvbwmRCWxcI5cg7rSQBN
JVe0jssH9w+fhhaAXp0DAqQSOnlrL4GPM12khrYfE8EfUi3B48Pt5zqjl+hGRm9gx6KPCsEV
vcH4Aezc1HqyLKTXwU9QAg0BCrcF3En3zDzcXWDGEvBcMgEUb3ouo5DhZQv2oz7nMUgPF6lF
VPaOen1SbtIHWFDMclxRQ3VC1z5oBYZcgjXN6DMEIKVA2MrajNBMjyYyZzkA1gHyGapp426g
p3lUNDHN4KofPGI4prt0D4DuC5ipjArPkqMiF3OSIlLtOwg5Tlgc0dJid++hWUvroY3S6Pzp
T8CTkhQmad/OwqmErdeD0meOEmGdvGdVMOeIZZnsys1xOxg3hCLsSyUMWZ48TuuuLi86KMNa
0zpmTqvtl832dbFeVoH4u1qD+WZgyDkacHAzjZn1DF4jeCTClsqpskCe3NJUuf6ltfA+ST3G
kRktkCZmIw+hoOCKifWovV64lBwiRHT9JQBaGUluAyePYuhIxj1f1D5x7Tha5uHYUiZKOpFs
z/5XoVLAFCNBi1odz9DOGOeziQwIa0EP0PRyLozxrU1EsDeJ5w1RTKdHDxLhvaG7AU9YjsyM
9ZG7BAeAUT4sLu+RHvoBmGvNRE4SwD7THVwrRjkRZW7hLHstduGWdaL1Q4+IiQb4O5fjQhcE
+IJIysKhGlYS8T1E8DV+JsJgCFsfAZUjArSW22aJekvIxNiAzwld1qY+95Kl/X3gUqHVqVGP
NpmBFgjmPHGPpuQcrrMhGztj37OBjYH2vMgSQHk5yHo7hdU3GcQpWyox8FHds3p7YaH6QmNP
qxH3wRm7Wy0NiwSA3BQzNr0R6lYXe3pooS48yQyIjUoXIRzjWWJ9RnA0NyUobD44mjEAijQu
xjLpGLxWs0/zgMOeCyqM4ICfOsCrT6ShTJcHri8RZ0fBaypiRqOMITcIrfabNXeMMp+ARXA3
HGUQhvbFgADtHjVNMFoTdY4J0z2t1KUOixh0H62QiFHchsJiHAX0Sathum2Yz+wxiDkYTVLX
u73uureo08djwiaPOzLQTAtro2NrTGiOCqvy1AXHcJ8AkPjDjGVha70aQD+gnDpddz0gMJuP
7kgCxFQQwjXWPorOOBC76Cnu2t4rDV+QR1vwy+JjoiKb0WDNx3zMYRCbb6xsDtY4b3VqJ7u9
pH53J0A1j0ulcT1993mxq56D7w7lvG03X1YvnYD0NAxyl0ev3YnknRmonYZzKhOBYtxK+CHG
NQh67i9b4M3JNLH3o7TbCDAG11Wk7cscYZhGdLN5VJgoBYUsEmTqJj5qupVVRz9HI/vOMpkL
X+c2sdu7m5BluUa/mKlZjwO1+1MhCoyIYRM21eJnyWZHhiZcgAN76oJhe9fpdrOsdrvNNtj/
fHNJiC/VYn/YVrv2C9AT6lvYzd41mFDRwSsmoSPBwH+Cs0L75+fCNNGRFZOrNOsYtDiSPosB
mBhEPQR8551HzHMwC/gycC7wqpPnMpP0MlzgDjeVO7teWgjhiVAnj+DtIZ4BpzEu6LQxmJ+R
1rnLtzdKcHN3S4c2H88QckMHD0hTak6p1K19tWs4wXJCxK2kpAc6kc/T6aM9Um9o6oNnYw9/
eNrv6HaeFUbTWRdlLb3wRCxqJhM+AfDjWUhNvvYFnTHzjDsWOhTj+eUZahnTLkLxx0zOvec9
lYxfl3Te3RI9Z8chLPH0QjPk1YzaoHueg60iYJqofuMzExnl9x/bLPFlj9YZPgVXAqaAzlEh
A9o5y2TTbKZoZY+QDArQbaix7u1Nv1lPuy1KJlIVyiKCCOKT+LG7bhtj8DxWpgNIYSkYnCAo
FDGgQwquwIhg452JamXM62Z7v52H9COFqZBgBxViRTYkWKCoBETm1FiF4q69MU0phGk2xiYv
O1QU9Ersk6oBd33avxAqzQcQ+9g+1TFgW5bRacyayytteAippG2avbSunDif1srJvG7Wq/1m
66BLM2srbIMzBgM+8xyCFVgBuPERYJ/H7noJuQYRH9HuSN7R6BEnzAT6g0jOfRlmAAkgdaBl
/nMx/v3A/cmQulqNLxY9N1Q33dB5zJp6e0PFQlNl0hic5HXnqaJpRdzrOVDHckVP2pD/dYRL
al22HEADzhf5/cUPfuH+0zNDjLI/FmhFgB1gz6VIGFEoYINmP9maiOPbIqDZtj2QMUpafIQT
+IpWiPuLE6Y/1/e4KMWSwob7DVo5rcjRiG3VnbujldaKu36t7EQzHERAuWwZW5dYEWrUhcCd
5nrQ9oCu0EcaDpFcu3s38KoBknv6T3qSf1oaXnma24mskbrp5UW5P1U5eQRTEIZZmXvLnaYy
A3upMS7tvFQbRTAf36BtiOyeKMPs/ubiz9v2O9Ywsqf0sl3L8tDRTh4LllhvSicuPIj9KdWa
TqE+jQoa2zyZYWr6CMvrEM9WjhzTnb4QB85FZBnGMTbv55QRH7Ha27JWCt17OZIaSzGyrEj7
d9cxmAZANkaEs/vb1qWrPKPNoF2TS4h4zSRs2B/XuGgDoAUdIbjEGG0yn8rLiwsqdfRUXn28
6Ej+U3ndZe2NQg9zD8P0o5VJhi/I9NuWmAvqWlElJAd7BIqeoaW87BvKTGBy0b6Tnutvs+fQ
/6rXvX6qmIaGfgfiKrTR88gnrGADZfRYxhDzES9QDgts/qm2AWCBxdfqtVrvbYTLeCqDzRuW
OXai3DptRBsIWlBMJAdzgpoG0bb630O1Xv4MdsvFSw9+WISZiU9kT/n8UvWZvcUHVo7RPpgT
Hz4PpbEIB4OPDrvjpoPfUi6Dar98/3sHFvHhZsJqt/q6ni22VYBkvoF/mMPb22YLy6jPGNrF
+vlts1rve8OBFwytOzuX5KMSNq6esc74tzt4InIULpKkY0+VD0glrbyJyD9+vKAjtZSjm/Kb
jEcTjQZHKH5Uy8N+8fmlskW5gQWn+13wIRCvh5fFQAxH4ORUjjlbcqKabHgmU8pNuUSlLjoW
te6EzecGVdKTP8BoEZ8pqOjGqfF1vyytTmZJ7bxB+3wJKft7BWg93K7+dq+mTU3falk3B3qo
sYV7EZ2IOPVFMWKaq9ST0wXLloQMk8m+4MQOH8lMzcBNu6oSkjWagfNhoWcR6DlntlyDOsfW
WvExOMzk1LsZyyCmmSeZ5hgwg1YPAzYaAl1PAQpAniY9RWfcjnVUYFxgWsnJrGybC+tZjiVq
rVCSuarYEI4wiog8JBqnZysEnftVOX3cOiKW4Z4ksNz5VNwM4Kqu9G4u1TUNVqBWuyW1BLgt
9YhJW3IhIuGxNpi2RATSP5/mqDNG+w9+RS5GCDhDFexOhraZ0FLKP6/5/HbQLa9+LHaBXO/2
28OrLUbYfQPL/Rzst4v1DocKwBdVwTPsdfWG/zyqGnvZV9tFEKVjBkZq+/oPGvznzT/rl83i
OXAFvUdeud5XLwHotr01p5xHmuEyIpqnOiVam4Emm93eS+SL7TM1jZd/83bKapv9Yl8FqvH/
v3Ft1O99S4PrOw3XnDWfeJDJPLZPF14ii4qjAurU+9Apw1NVouFG1tLXuvWTezMSwU4nrMM2
X0ZeMQ4+V5tJvYhh7aFcvx32wwkbT5ukxVAsJ3ATVjLkBx1gly58wuLJ/59eWtbOszBTgtQE
DgK8WIJwUrqZ53RWCUyVr+gISA8+Gq4K8Cra6R4sac4lVbJ0db+efP/sXFyRTH2GIOV3f1zf
/ijHqacqKjHcT4QVjV3A5M/n5Rz+64GxEMzw/tuZk5MrToqHp6zSpHSW2qSKJkzMEHKmoDHE
nGk6FGNsqz952tii3i4wzdNg+bJZfu8TxNqiMYhQsEgbQwIAJfgpAgYt9ggBGagUK5f2G5it
CvbfqmDx/LxCBLJ4caPu3reXh3fTK/k+0WYeNIlpx5JNPWWFloqhLQ3ZHB0D65jWgslMebId
+URkitFB1bHwm0qwmFH7CxhnuDbr1XIXmNXLarlZB6PF8vvby2LdCWGgHzHaiAMq6A832oK/
WW5eg91btVx9AfDH1Ih10HEvqeGc9+Flv/pyWC/xfo5m7flk4xvDGIUWgtFWE4mZNqWghXuS
I6CAmPba2/1BqNSDEJGs8tvrPz3vMUA2yhd3sNH848XF+aVjCOx71gJyLkumrq8/zvGJhIWe
Z0JkVB4j40pkcg9UVCKU7JjnGVzQeLt4+4aCQih22H2HdXiEp8Fv7PC82oA7Pz1S/+7/RhEG
KUH9CONruaLt4rUKPh++fAFPEg49SUQrLpaYxNZzxTykNtdknMcME6IepK2LhMq4F6BQegJh
cizzHEJ3iJYla5VaIX3wsSI2nqovJryDCgozDD+xzUK/5y7mwfb0288dfjkaxIuf6GKHGoOz
gVGkXZJOLX3OhZySHEgds3BMhHx2epudCasXnPanNcT5z7fqHfetpIhT6fXNxYy+RKU8wi6U
8WbFEgERnQjpmVw9ohxJuLdH4l5FyPgx/oU4vWh96mdJgzvNwLSA9HYbFL+8ub27vKspjR7m
+AEMM54QUDEiUnNRtmIQfpGZr8eEYxmfJ8tUzENpUt+nCIXHXth8uQ+ATldbWAV1z9hNari1
7rB1kLbcbnabL/tgAnKyfTcNvh4qCB0Iq+IiWzR2/bR6O/wf96qTO+mcY5UIFfo2cH8C8Zg4
8Q53egLN5m21tmikp4jcNprNYdtxWsfx4weT8VLeXX1s1bNBq5jmROsoDk+tzQXmSsRlKmnT
BWGCRY0lV//CoPKCLhk4ceSK/uZHqJoBNM4Tssh4pOmMnNRKFV7XklWvm32FIR8lTZj/yDFm
5sOOb6+7r/3LMMD4m7HfSAV6DeHH6u33Boz0wsYTWjEb3h9o9V7Ne+3NcRXJXPqTArCG0nNM
SHryeJnUCmo/sdxcwTz34gP7pkifvUe50xn16sVAWcZg9BSbl0nWrumTKdbB+ky3Rbm26DzT
sS+0itTwDtE1tT9qG2SufL4LgX46Z+XVXaIwCqFdRIcLHBAt/QBJywedMMvhnxHxOve8KSk+
dNxEHQNl6DI2tDls/bzdrJ7bbICLMi1pbBoyTyrcG0abnG5372L5ZLAim1nqoLfWM0Jzxcg1
6AoxIrHviAgdo2PqKhwqnQg9qdtjdhf26nvyC0Ucl9mItm0hD0fMV7Gox7E4TUEk7L5uF62E
WyejFeFjgZPslj8IXfEURKut71Fah1J/zMY4Hd6JORpRYHPv8dpTYWKreZHD5x9hBJHw7HHw
LNvisB9NeDI0Z2jS0UrvV38RO9P7U6FzOitmKTynzwXz1pG5KT0vBRGWnXloGgAOYKMe2Yne
YvmtF2iYwXO9U/ZddXje2Aei5sob2wH+yze9pfGJjMNM0DeBZeC+FxD8NpKOdt2PVJynll5s
5f4PpMQzAL40WSlzX5TRTEk8PNL6w7tvi+X37hfS9qddZPYpitnYtCC27fW2Xa33322E8fxa
gdtvQHCzYKOt0I/tj1wcKzju/zhVyoKuYbXCgOOmvuzN6xtc3zv7OTfc+/L7zk64dO1bCni7
BxusaqG11RYRlWA78Ed00kxwCDE932g6VlXYXzkRZB28K1fG0e4vL65u2uY8k2nJjCq9X7li
AbydgRna9BcJ6AimIdRIe77adJVXs+Ts81ZE5ssFPq4Zt7PhB5RGuB8aAqlSmL+iZb3H5I5V
JzEVwjWfQnVqvHtF9f9W/V3vSNtfVBDs4VjG44HACJ1AH7pvTZ2h3BcdR6lWAH0hbg6rz4ev
X/s1jnjWtuDd+Cx07+dj/FcGWzQ68bkCN0ym7Ueh/Z9G6XHp0V9wC94XkXqT4IljOK3hPR8p
Z2ZwH1wVxmeYHNeURq91VqXmgUC0V0zXIZwZvi7Sw7qm81u1q0UHEsX2tzuozRzJvpHssvFk
fMox6b1e1k/uIDRBDKHn4c3Zqcli/bVjnND/FymMMvzSrjUFEsEfJO5nH0im2ScyrdwSsgQk
H1RT069lHXq/LtIRMbrEmodB5ZPXtjqyExf8baeB0ewdI87wIERK/bYGHmOjhsFvuzrU3/13
8HrYVz8q+AeW27zvFtzU91N/0XNOnvBr/7Nv/rOZY8Ivtmcpy2kT6Hgt8juj8pmengd//9fI
1ey2DcPgV9kjJMsw7GrLcqrGVTz/FHEvRjfk0NOArD307UdSsmXLpLJjQlqWJYqkJH4fNYDH
nYmXTMdfFQzZnb7AawjF2+qqlNE/9FIwwxkkxJvaPA6+Menkx5PBJbp2cs4q1XmTdHa1uafR
pjzqhDlOTbtqdIGQmozJlJB/hQ8NNMESPYtnBkJ+lVRouzsT1AAW2ic1/qsZeaaIqean99ip
5eG5kMZGjr/TeI+6ac4NOI5HLRcMu+peVmfKh2aAt8A6SM677K0KPCkxiHqWHpusfuB1JjQ9
C/1fCwmUzCHSvfiJcMigoGB3Gan4CkvXBweaj1Hl/kHXShDiE7jEwwCEUdzMrLNcpD+CJLq7
/n2PbJdqm3BVETUcb5k6Jc3DhCAqWra7nECmotz5t+/f0o6G+vKgL2LNl+sspN/26MvY+OVO
eidQ7IRDUlIgKhq+bJDkuemkIw6S971wQkTSBuHam3Lf6FslRPeKqiHRg0KkPIIMRxxnyi2t
4yXhy8WDf8ueah5dvMimjsXqygV/pxLGPm8zCy1Dvof8SQ4GHUwlUF84RXserUTsQxrp5PSZ
kBCtKyvUqwtAvLaAdDE/tw4zIfBKuVL9BHERXX90aLXypXPQSTle3lod88QG4h6nXFVeVr0E
+HW3ArBKZRIXvEQSvK85O+rSsRtqPe4uP3YhpYxlMMZ7XubMNfBhrqWEiTtsZPSyZVlzEAib
+1kjsTxmHRvVs85D6mPWsovLfFnV2XZ1etlMDbagJI0mC9IQ4Q5hRk+OpRB66x4JOdGlbnvg
rmWuvz9ub++f3BnKSQ/C4ZZWfWO6AXyPbumSgSgPkrpypXAHYRRjOiKvtgXH0SCHV2cLiFQs
XZOL4mGqzAz6vAL++C2oeZHZl3Jjs2ZgQoLbsbz9ur3ePr/c/nxAiL0uDsJmmp+usaoexhLr
TfHDGSYgUKm0FaSlsRM7b24YckbEB0zV4ZFI/JvhsSDyAKKJqyuz5otSjRqVMh0/5SDd88BN
fK7b7wrDh1IUmw7SUkl64O+JQMIX/1Qmp6ckPlLF49yJQdTzcroifAacHRIaqow5fE0nLJcX
ZOtOiMZcPbJG2uKsLVGE7i/0umvEHwUx4qpdJQcWNvfifQQqUD2BpICJp/DhRcHvYIhNVeTK
83hCSRgj6GKrbLEyIDOWMVgMSiPFNRD+A7Vrdg3DXQAA

--k1lZvvs/B4yU6o8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
