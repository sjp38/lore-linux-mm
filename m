Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 869046B0006
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 00:54:02 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id g24so5002813plj.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 21:54:02 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id i12-v6si1164774plk.139.2018.02.01.21.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 21:54:01 -0800 (PST)
Date: Fri, 2 Feb 2018 13:53:00 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/6] Protectable Memory
Message-ID: <201802021349.3PPjTUdu%fengguang.wu@intel.com>
References: <20180130151446.24698-5-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Content-Disposition: inline
In-Reply-To: <20180130151446.24698-5-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: kbuild-all@01.org, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Igor,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.15]
[cannot apply to next-20180201]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/mm-security-ro-protection-for-dynamic-data/20180202-123437
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/pmalloc.o: In function `pmalloc_pool_show_chunks':
>> pmalloc.c:(.text+0x50): undefined reference to `gen_pool_for_each_chunk'
   mm/pmalloc.o: In function `pmalloc_pool_show_size':
>> pmalloc.c:(.text+0x6e): undefined reference to `gen_pool_size'
   mm/pmalloc.o: In function `pmalloc_pool_show_avail':
>> pmalloc.c:(.text+0x8a): undefined reference to `gen_pool_avail'
   mm/pmalloc.o: In function `pmalloc_chunk_free':
>> pmalloc.c:(.text+0x171): undefined reference to `gen_pool_flush_chunk'
   mm/pmalloc.o: In function `pmalloc_create_pool':
>> pmalloc.c:(.text+0x19b): undefined reference to `gen_pool_create'
>> pmalloc.c:(.text+0x2bb): undefined reference to `gen_pool_destroy'
   mm/pmalloc.o: In function `pmalloc_prealloc':
>> pmalloc.c:(.text+0x350): undefined reference to `gen_pool_add_virt'
   mm/pmalloc.o: In function `pmalloc':
>> pmalloc.c:(.text+0x3a7): undefined reference to `gen_pool_alloc'
   pmalloc.c:(.text+0x3f1): undefined reference to `gen_pool_add_virt'
   pmalloc.c:(.text+0x401): undefined reference to `gen_pool_alloc'
   mm/pmalloc.o: In function `pmalloc_destroy_pool':
   pmalloc.c:(.text+0x4a1): undefined reference to `gen_pool_for_each_chunk'
   pmalloc.c:(.text+0x4a8): undefined reference to `gen_pool_destroy'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--0OAP2g/MAC+5xKAE
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICOj2c1oAAy5jb25maWcAjFxbc9u4kn4/v4KV2dqaPEziWzye2vIDBIISRgTJIUBJ9gtL
kZVEFVvySvJM8u+3GyDFW0Ozp+qcE6EbIC59+brR8C//+SVgb8fdy/K4WS2fn38GX9fb9X55
XD8FXzbP6/8JwjRIUhOIUJoPwBxvtm8/Pm6u726Dmw+Xnz5cBNP1frt+Dvhu+2Xz9Q26bnbb
//wCrDxNIjkub29G0gSbQ7DdHYPD+vifqn1xd1teX93/bP1ufshEm7zgRqZJGQqehiJviGlh
ssKUUZorZu7frZ+/XF/9hlN6V3OwnE+gX+R+3r9b7lffPv64u/24srM82AWUT+sv7vepX5zy
aSiyUhdZluam+aQ2jE9NzrgY0pQqmh/2y0qxrMyTsISV61LJ5P7uHJ0t7i9vaQaeqoyZfx2n
w9YZLhEiLPW4DBUrY5GMzaSZ61gkIpe8lJohfUiYzIUcT0x/deyhnLCZKDNeRiFvqPlcC1Uu
+GTMwrBk8TjNpZmo4bicxXKUMyPgjGL20Bt/wnTJs6LMgbagaIxPRBnLBM5CPoqGw05KC1Nk
ZSZyOwbLRWtddjNqklAj+BXJXJuST4pk6uHL2FjQbG5GciTyhFlJzVKt5SgWPRZd6EzAKXnI
c5aYclLAVzIFZzWBOVMcdvNYbDlNPBp8w0qlLtPMSAXbEoIOwR7JZOzjDMWoGNvlsRgEv6OJ
oJllzB4fyrH2dS+yPB2JFjmSi1KwPH6A36USrXPPxobBukEAZyLW91d1+0lD4TQ1aPLH583n
jy+7p7fn9eHjfxUJUwKlQDAtPn7oqarM/yrnad46jlEh4xAWL0qxcN/THT01ExAG3JYohf8p
DdPY2ZqqsTV6z2ie3l6hpR4xT6ciKWE5WmVt4yRNKZIZbAjOXElzf31aE8/hlK1CSjjpd+8a
Q1i1lUZoyh7CEbB4JnINktTp1yaUrDAp0dmK/hQEUcTl+FFmPaWoKCOgXNGk+LFtANqUxaOv
R+oj3ADhNP3WrNoT79Pt3M4x4AyJlbdnOeySnh/xhhgQhJIVMWhkqg1K4P27X7e77fp960T0
g57JjJNju/MH8U/zh5IZ8BsTkq/QAoyg7yitqrECnC58C44/riUVxD44vH0+/Dwc1y+NpJ5M
OWiF1UvCygNJT9I5TcmFFvnMmTEF7rYl7UAFV8vBojgN6pgUnbFcC2Rq2ji6UZ0W0AdMl+GT
MO0boTZLyAyjO8/AT4ToJmKG1veBx8S6rMbPmm3q+xocD+xOYvRZIrrXkoV/FtoQfCpFg4dz
qQ/CbF7W+wN1FpNH9B0yDSVvy2SSIkWGsSDlwZJJygR8MJ6PXWmu2zwOZ2XFR7M8fA+OMKVg
uX0KDsfl8RAsV6vd2/a42X5t5mYknzrHyHlaJMad5elTeNZ2Pxvy4HM5LwI9XDXwPpRAaw8H
P8EWw2ZQ9k475nZ33euPJlrjKOS+4OiAy+IYLatKEy+Tw0BizEfoZkg26zsAPyVXtFbLqfuH
T18LwKvO5QA2CZ1cUU58hOoADEWC0A3ceBnFhZ60F83HeVpkmpyGGx19gGWiV4yQil5kPAXr
NrP+Kw9p68VPAAKVHgXZwuyEC2Lpfe4uHGMJ2BKZgDHRPUdRyPCyBfZRd00MksJFZg2QBdq9
PhnX2RQmFDODM2qoTsDaO6jAfEuwrzm9hwCfFAhWWZkMmulBR/osRzRhiU+XAegBFhqqa8OQ
y8RMPZI4prt010/3BaBURoVvxoURC5IistS3D3KcsDiihcUu0EOzRtVD0xNwjySFSdphs3Am
YWnVedB7CmOOWJ5Lz7GD5vBplsK+oy01aU4f3RTHf1D0J0ZZdFYmUOYseOguvN4SDDhCEfYF
G/qUJwfVOu/Liw48sca3Craz9f7Lbv+y3K7Wgfh7vQVrz8Duc7T34JUaq+wZvIL+SIQ5lzNl
IwByTTPl+pfWIfgEug5Ac1qodcxGHkJBYSAdp6P2fLE/HHA+FjU882mtgQgUAUUJgFlGkltE
49HBNJJxz8O1DyZ1HC1DVLeUiZJO+tuT/LNQGSCVkfAIh4uXaBeP37OJEgibQeXQyHMutPbN
TUSwNonHAlFSp0fP6+DxonMD/1qO9Jz1IwMJioCuCCZneqRpP8BzrbkwJAE8Ad3BtWIUFVGG
PSoSl+cReQ4+RCZ/Cvu7xwZb3mux67MjTtJ02iNivgN+Gzku0oJAfhDQWSxWYVoizQBW1sgI
QInFogSDFqbC+YSnh/D6AaIHxKfW19hsVm+OuRhr8JKhyy5V51eyrL9QXAu0Oq3t0SZzUDrB
nGXr0ZRcgFg0ZG2/2PfFYLOg3RR5AhgUVizbqba+hSKOYcLyEOFOkcEEDZxdBRuoQYjv10Yo
r3YhLFRfRu2mNtrV30VAeA57RbkYnpMTnVKzSACMzzA71RuganVxtocWpoUncQNxYOlioDp2
JyavBUcLWYLxMIPtHQOMyuJiLJOOjW41+6wAcNhNQ+W1G9/BkX0iDeC6PCACiTg7Cp5hETOP
kx1wg+CnpIk1E4y3YHPkbGAy3O5Ky+KkIsohEu+zEdGKx0QkGKaKKs2GGa++pqRhdVCZ4Og2
WtndNCxiMF9oSEWMIhwTtsBSQJVTNcxIDlO+PQaxALtP2qFur7vu4afZQ53TMnFHdJrPwtzo
9APmfEeFtTaUXMQgBgAn+XQO2t2abwpREmDCKqN5PSCw2nQ3IgHBJsS2jcOKojM+0E56hqu2
506DQeRJbaTA4jqXk89paOtjpnDEwMAb8BSm1al9H+Al9bs7AfLwZJMHiOvTbvr9RM0xP1ok
neCmbhvgfJfI5Onst8/Lw/op+O6g4ut+92Xz3EkCnMZH7rLGNJ3siTNMla90vnQiUINa6VYM
NjQix/vLFgp36kJsa61IBqw02NoUHEZ7XSP0IUQ3m8WGD2VgC4oEmbrJpopu1cDRz9HIvvNc
GuHr3CZ2e3fT4cyk6O1zNe9xoOH4qxAF5iBgETa95WfJ5zVDE7fBhj12oxp71tl+t1ofDrt9
cPz56hI/X9bL49t+fWjfvz2iKofd3GmDmBWdRMArgEgwQAXgPtH0+rkwNVezYmqbZh2DgYik
xxghpExxt2lTBWEH6FhIY36cg1gYsEZ4Z3MuOq6uNWQuzyVX4BSNczelBU2ecHLyAMAFglJw
ceOCTuiD1RulqXE3IY2C3Nzd0vHrpzMEo+noDGlKLSh1u7X3qQ0nGGwjCyUlPdCJfJ5Ob21N
vaGpU8/Cpr972u/odp4XOqWFRFkHIzyxnprLBJBGxj0TqcjXdL5CiZh5xh2LNBTjxeUZahnT
nknxh1wuvPs9k4xfl/SNiCV69o5DQOfphSbKqxmVsfdc1FtFwFRedfuqJzIy95/aLPFlj9YZ
PgM3A2aCziMiA9pAy2QTNbpoZfiQDArQbaiQ+e1NvzmddVuUTKQqlAUiEURk8UN33jaq4iZW
ugOfYSoYjiGEFTFgWQolwYhg/52Bat1gVM32fDslDjWFqZBgBxViRT4kWPyqhGHkWIXirr0x
TRkEpjY7QR52qCjEl9jLbg2u/LR+IVRmBgFB3T5LY0AhLKdTzRWXV9pwEzJJ2zR7aF05cf6u
lfR62W03x93ewZrmq61AFfYYDPjcswlWYAXA1QdAmx676yWYFER8RDtUeUeDVvxgLtAfRHLh
S+8DgACpAy3z74v2rwfOT1J5xyTFG6SeG6qabuhkc0W9vaEit5nSWQxO8rpzddS0Itz2bKhj
uaI/2pD/dYRLal62UCOF8EKY+4sf/ML9p2eGGGV/ToAY1lyCjcofsn7RSwTIwlEZUeBhEwB+
sjUg9Z0w3q62rIWMUQ7jGmzgnWch7i9Ogca5vvWkFEsKm7posMxpRo5GLLrq3B2ttDbe9Wul
YZrhICwz7fDYhc9CjbrgudNcDTrIPdbxxbjIejsWSs0h8GwP3I0TK2DlijmSnsacJo2ikhk7
BWvcbnoJa+5PDmNcxsIwL423gG0mc4Ox26jowPWpVgRzXVVgI3p31Rzm9zcXf9y27AqRqPAH
tS7LaCYQKs9ZRul9u4pp2tF+HguWWG9Np3E80cJjlqZ0cvtxVNDY6VEP7xbqkKA6flszVCei
O65G5NbLgch5ggpwIyPQ14linosHaxcRUJQjmWJZTp4XWf/UOyYayyAwPp3f37bERZmcNrz2
KFzmxzsB2AJ/lOWiGwDeNEuVOaSt9GN5eXFBJQcfy6tPFx2leSyvu6y9Uehh7mGYfoA0ybGI
gL48EwtBnTRqk+Rg5OAoczTOl33bnAvMvto07rn+9qoD+l/1ulfXT7NQ0/eHXIU2mB/55BcM
K+b649BQF3wOfuz+We8DgB/Lr+uX9fZoA27GMxnsXrHmtRN0Vwky2rbQkqIjOfgmiH8Q7df/
+7bern4Gh9XyuYd4LKjNxV9kT/n0vO4ze+tPrCCjydAnPrzyy2IRDgYfvR3qRQe/ZlwG6+Pq
w/sOEuMUyIRWW2IbC1sih211OU24Pmy+bufL/TrAvnwH/9Bvr6+7PcyxOgBoF9un191me+x9
C/xuaB3ouVwnlVxyla/VnUu7gydDgJJHktLYUw8GIkvHf4kwnz5d0JFjxtH9+Q3Kg45Gg1MR
P9art+Py8/Palm4HFiwfD8HHQLy8PS8HMjoC56kMpq7JD1VkzXOZUe7P5WvTopOdrDph87lB
lfTkMzB6xRsgKtpyOn7dL2CsEm8y7XkP2N/BFoXrvzcQPYT7zd/umryp/tysquYgHapz4a7A
JyLOfFGVmBmVeVLbYPaSkGFO3Rcs2eEjmas5uH9XjUSyRnNQIBZ6JoGedm5LfKh9bM0Vb//D
XM68i7EMYpZ7En+OAbN91TBgwCHwppcH0tpKl9GOvK6zA8sDn5WczCC3ubAGylPoiORZEWO1
9EgCBJSiW/sA+m6LrEPY5ygiEqto3p6spHSEQBn6TNKImKu7vsHq+VOtPCC76uFAc/KuaTCD
ZKZE3/ypzWFFTQuOWT1gZpqcHKCjONWYm0Vg09/Y5oxy5snsgaaWudG0DeNX5PSFgKNRweG0
gGY6llL+cc0Xt4NuZv1jeQjk9nDcv73YopbDN3AIT8Fxv9wecKgA/N86eIKd2LziP+u9Yc/H
9X4ZRNmYge3bv/yDfuRp98/2ebd8ClxFefArOtLNfg2fuOLv665ye1w/B2BBgv8O9utn+/Ll
0N35hgUlw1mJmqa5jIjmWZoRrc1Ak93h6CXy5f6J+oyXf/d6ugrQR1hBoBqU8itPtXrfN3k4
v9NwzenwiQc/LWJ73+MlsqioLUHqSW4g25mKZxmeSms117KS9NZRnHywlgjXOtEutvmuOBTj
AAxSPakmOCygldvXt+Pwgw0cSLJiKOQTOCUrZ/JjGmCXLgDECuD/n12wrJ2bf6YEqVcc1GG5
AlGn7IAxdCoO7Kmv3A5IUx8NZwWIG51JDzs1+5IpWboySM8lyfxcaJTMfEYn43e/X9/+KMeZ
px4wAaPkJcKMxi7m8ydBDYf/eoA4xGO8fxnp5OSKk+LhqRnWGZ3a15miCRNNt2fZUGYzkwWr
593qe99Yia1FgBAyobJhjAJACB/KYBRldwTQiMqw7u24g/HWwfHbOlg+PW0Q9Syf3aiHDx2E
LRNucjpywmPoqfWJNvegW0zLlmzmqY21VAzEaQjp6HjvGtMCP5n7isHNROSK0euoHypQiSQ9
ar/dag5SU9ZsxAFgUOyjXlrFefW35+Pmy9t2hbtf26Cnk7FurFgUWlBHmzgk5qkuBS2JE4Po
A0Loa2/3qVCZB3MiWZnb6z88N05A1soXybDR4tPFxfmpY8Ttu7gDspElU9fXnxZ4CcRCz0Uo
MiqPRXAlS8YDPpUIJasv8gcHNN4vX79tVgdK88PuTbODIjwLfmVvT5sd+OXTFf37wftYx6zC
IN583i/3P4P97u0IkKZz6txbvwOfRm9K2FfbP9ovX9bB57cvX8BZhENnEdEKixU/sXVOMQ+p
LTlxzsYM83IexJ8WCXUTUYAipRNMAkhjYoFRu2StgjmkD57XYuMpQT/hHcdf6GEYjG0WKz51
IQ+2Z99+HvCdcxAvf6IXHeoZfg0MJe110szSF1zIGcmB1DELxx7TZSAKosUXOxZxJr2+tpjT
J6aURx+E0t48XSIgjBQh/SVXhipt6PRAHKIIGa+Dbs3zovUS1ZIGB5iD9QFR7TYofnlze3d5
V1EaVTX4KotpT9ypGBEeutBeMQjnyFzcQ8Kx8tKT9yoWodSZ781M4TEpNvnvA5SzzR5mQYkX
dpMpnFp32CrAW+13h92XYzD5+bre/zYLvr6tIUwgDI8Lp9Eeeu8IQDvHveL2Tg6pLpWh4u2W
/YFoTZx4PYV787quaQhYLULRu7d9x6vVo8dTnfNS3l19alUSQquYGaJ1FIen1ub4jBIxABTP
g4CJw4AlV//CoExBV02cOIyin6EJVTGAvnkCEBmPUjqAlqlShdf35OuX3XGNwR0lS5hyMRhP
82HH15fDV7JPpnQthX7TPZf58Ppdw3d+1fbVX5BuIRbZvL4PDq/r1ebLKXd2Mrbs5Xn3FZr1
jvft8GgPMflq90LRNh/Ugmr/6235DF36fZpZF8lC+pMYMPXSDLPrC6yL/OEbc4GPQxblzPP6
MLOa08+9N1KxMF5MY+9yaXHwnEo2H7p4zPis4BCGITIDrR6DdVZsUSZ5uzqzpsyuS+m5U5MZ
1lv73JCF5fZhRZ7GvrAvUkOJRJ/afjU6SP35nC6g5nKaJgxd5JWXC2ObbMHKq7tEYRxFO8UO
F47nDzC458pO8SHiIApTKKOds6GnYNun/W7z1GYDQJenkobiIfPcJXhDfG3odnftaGhwafNo
JMEToWrpsW86lqonSw6f1km6cKh4IvTkvuv0OKzVd6Maijgu8xGtsiEPR8xXnpqOY3H6BJGa
/LpftlKLnUxchLctTrJb3i101XAQereeZrV2snolyjgdj4oFugRgcyUUvqyaLd1GDp+vhxGq
ihZfrUOk7bsfT/boDE06Wul9ahuxM73/KlJDS5mlcEPvCyb+I31Teq5aIqwj9NBSAGuA83pk
J3rL1bdehKQH9RFO2Q/rt6edvWFrjryxHeCNfZ+3ND6RcZgL+iTwOYHvCgkfJNPwy/09mPPU
0osT3f+BlHgGsBcAKGXucSXNlMTDLa2eqn5brr53/wSB/StK4L2imI11K1ywvV73m+3xu81b
Pb2sAcQ0gL6ZsE6t0I/t35OpS2vufz+VPoOuYS3YgOOmOuzdyysc32/27yXAua++H+wHV659
TwUR7sYLy41obbV1XyXYDvx7VVkuOMTGnpfRjlUV9g8KCfLRg6s/x9HuLy+ubtrmPJdZybQq
vY+U8bWD/QLTtOkvEtARzLqoUep5S+1K6ebJ2fvBrsDU8ibwdlK7lQ2fHGv3thOlSmHCjZb1
HpPb1jTx5Puq2aT2z40INq1rnjxgHPEPyHL3vqwzlHvVU0ukAhC+/xn8XyNX09s2DEP/So87
DEO7DsOutuMkWhzZ80fS9GJsQ1D0sKJYG2D79+OHbNkyqe629TG2JVEUJfG91fnH5eEhLDjF
fiL2QaNF10BlSe/uqjRNabUwzo+pS+I2hwpCgVWZIoVWZQ26RsIqWkBvLcdoQCJvYFJe12hB
ha0OUiHceJTjbGArEtQuzoDI411NJKpZxJtKX4vBf12Q/I3UmAGONXobXLK6kgLwi6sC9rmX
Zw4j2+9PD/PdSbluA4asHKuXTFrlcxCE0G5ZIkU0On4Tj7QnPmdhIsAsK4PUQsLDqlQGcduL
9R+LEjE1TDLM3oOKaIv4F3Q5vmGX55WkQ4Nd7mfl1buX58cnurp4f/Xr8nr+c4Z/YF3Sh3ll
khtL4cQidC+Uy4jWPxyPbIRyBccqUZJptqUkLhIB6vIQz+PoAXjkGnnJcCpXQJe98S3wGuKU
N3mx1llb9FJww5HcJbva2A/uYdqBlJNQlB+CMR7FfDrb5DmSuSJXhy5QcaCLtVTT+3FR2bxl
0cSi8UCXj/lIVkNbbGsSIUNCYSN5WSFv0HSP3hwPZMQTFSJq8V+P0ceLtJ2+uTAemyROPayv
9UV56MhQAkLZVGAdtWgzJDijmoCi2DnXnSCjkJQ/ops6qbayzaDwIMpazEFis0vyBw7eM6cX
8kbYLgYmriCVv4GFHEKVAvfD/cAWnqTaONF9B/he1Ed2JjexdFqUFIO8uT2/vAZuS/VgOKFI
eFH23TyGpn7IkFCve2ZKJGIVJyYFLFl93IzD5edP8bhFn7zN79RyOm4TJOZ24yoE5YBAdjsw
bJXDEjIgaSi5IpPw1LTa4QfhXaecHRFa44Xiosw6aKt250jo2rAcQeQLVqoCGaRsaj9T5mpZ
vEeu0/dLSbKvZJK5FxHYbVaziyX8fywd7dImsfBkyCZRzozZ8N5VPOOCDW3ZW01oiyziqe+B
yCsNV2zmsztNvJyBZDQtG6a5KDJvzJqICInRJU+LXqvfvnubWASXvZUlUXQxJpfBFSkp3Glj
hTdhSpQ2JcsD07Vpf3335donoCEGXXgjY+yNXnN2jhK78XaB0cumBeEeUHb1o0XE+0cbG1QC
jz3m1rbpJ06z66xKllHZYaMQ30T2NxgLyEOUe4eRB9uvlSW6s0eY+LCuqtT40BBp8c1Y0nf+
efn9+PpXOlrZ5SflzCvPutq0J1iR8obuHkhRI2qrHQvOxJy0/LSF9RqTB6TZLWu9g1HyX5dM
+HAhOlcAxmNYXb73MONouQ2wudclzFJjk/okLBm8QVoWlrjfjSJYbW2z6gRjWu6p4ctiajQp
cqugtBiwNjYsCUscqRlDYX4ABX/2sluoJ0EKjlVh5gJrWZ31WWZa2QMAvZH5uvi79uZ6ZeRl
FWHTQq6robfyPREgst4BAHKpVGFSepymHJzJugekA+x0c5kEIZD1fXJE26bbj/Gs5u4edfUj
UJ9mX0V4GEDazCYtE+T1F+nmwyonzocGHWTKTuU/4QoRMkkbp57jZ/KmiGy1Mb1dmRpPULRL
FTShAg+1lhmSbaX7Vyv50IaUmVWZTcdW1cCQdxlOmoZKxcxMeMllpNLg/ANd2vqk9mEAAA==

--0OAP2g/MAC+5xKAE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
