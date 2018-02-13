Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFAE56B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 21:43:49 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id d21so7782932pll.12
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 18:43:49 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g17-v6si4471701plo.357.2018.02.12.18.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 18:43:48 -0800 (PST)
Date: Tue, 13 Feb 2018 10:43:27 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 5/6] Pmalloc: self-test
Message-ID: <201802131011.XACTqdLh%fengguang.wu@intel.com>
References: <20180211031920.3424-6-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
In-Reply-To: <20180211031920.3424-6-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: kbuild-all@01.org, willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Igor,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.16-rc1 next-20180212]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/genalloc-track-beginning-of-allocations/20180212-192839
config: arm-allnoconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All errors (new ones prefixed by >>):

   mm/pmalloc.o: In function `pmalloc_prealloc':
>> pmalloc.c:(.text+0x268): undefined reference to `vfree_atomic'
   mm/pmalloc.o: In function `pmalloc':
   pmalloc.c:(.text+0x2ac): undefined reference to `vfree_atomic'
   mm/pmalloc.o: In function `pmalloc_chunk_free':
   pmalloc.c:(.text+0x86): undefined reference to `vfree_atomic'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/04w6evG8XlLl3ft
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICBtHgloAAy5jb25maWcAjDxbj9s2s+/9FUJ7cNAC50v2ljTBwT7QFGWxlkRFpGzvvgiO
V0mM7Np7fGmbf39mSNnWZeg2QLC7nOF1hnOnfvnpl4Ad9puXxX61XDw//wi+1ut6u9jXT8GX
1XP9v0GogkyZQITSvAHkZLU+/P12sX0J7t5cv3tzFUzq7bp+Dvhm/WX19QA9V5v1T7/8xFUW
yXHFivT+x/EP/aArXea5KoyuWJ5WIi0TZqTKzjiZqqRCjCpleaurYXxiCsbFcYQzLFF8Eoq8
BfglaECuhyw+RQkbnyYPVrtgvdkHu3p/HKOYaZFWcx6PWRhWLBmrQpq4tfaxyEQheRXPhBzH
ZgjgLJGjghlRhSJhD60dCRFWYcpwQ7gPI84wVvD4fCRlXqiR0GdwHsOJqSjSwtxf/X119eEK
/52gY8NGiagSMRWJvr85tociOp6M1Ob+57fPq89vXzZPh+d69/a/yoyloipEIpgWb98sLd1+
/glI9kswtrR/xoM5vJ6JOCrURGSVyiqdtmgiM2kqkU1hFzhVKs397WkRvFBaV1yluUzE/c8/
n2nStFVGaIoSQE2WTEWhkS3a/dqAipVGEZ1jNhXVRBSZSKrxo2wttg1JHlNGQ+aPvh7KB7g7
A7oTnxbemrW95D58/ngJCiu4DL4jjgM4gZWJqWKlDZL9/udf15t1/VvrVOFOTmXOybFLLYCn
fcdseZeVIBdgDCBNAnu2XATXLdgdPu9+7Pb1y5mLjhcFwJVl9OEdQpCO1cwPcczepkURAgyu
9gx4WosspPvyuM0M2BKqlMmMaqtiKQrc3UN7niwEnm0QALfbMVIFh1tu4kKwUGbjluDKWaFF
t4c9OY5iS6sSOlYhM4yQKIgB282MPh6tWb3U2x11uvFjlUMvFUre5j0QpwCRsHaSwhZMQmKQ
cniilZEp3Lk2jl0Jz8u3ZrH7HuxhScFi/RTs9ov9Llgsl5vDer9afz2vzUg+qaBDxThXZWbc
AZ2mmkqQ9l0wngG5LDxsXFELd7C0gpeBHp4Q4D5UAGtPDX9WYg4HR0ki7ZDb3XWvv2F6onEU
crE4Ogj8JEGZlyp6R4hkVYQWYz5CiU2ijUqZhNVIZjf0XZUT9wuxjyM/aR7DNJar2nvg40KV
uSZHdV1Q2FokegOo7ug1JxMQQVOrKIqQWBnnlcqBnPJR4BVCDoYfKcu46Kywh6bhF59UKmV4
/f5MNUfc9mBgchgJkq2gNzwWJgWiVo1Mo5EedKQvYkROXpCwXGk5J67VGaGQmZl4uGBMt4Mu
r6LSt5rSiDkJEbny7VGOM5ZEIQm0i/fArMDywJiklRgLpxI20JwofSqpSEesKKSHcMCofJIr
ODmUWkYV9OFPcPyHlJ5ilEcUVY8bS0ciDEXYMwSQZ6uTlD6SEBuByappCoOpjkjO+fXV3UBo
NWZ0Xm+/bLYvi/WyDsSf9RokKgPZylGmguR3orc1h5uY3M00ddDKCkofs6E1xgyYeDTD6YRR
BoBOylF7TzpRI29/IF0xFkdjxI8WFUKg/KsKuDwq/ReIqP1BuNHMlqK9jac/q8oMRZAEC/3R
gwxkN+AAoCKuwMaUkeTWMfFcUBXJpKd62jyhHEZHiDXGPa1ssdP7uxHY07DGcYYyl3OhNTGB
NR6QtVAjgFKqRnrG+oZulspei+1m3aFYqcnQ2ADL3poJjQ1DWFEIRHEBisqUec+aiZnGdryl
qngg57bjgj4sSm6qWSyNpWEPtRDgpgH5ncPXnAL4iv3t8GTSa0EPC/CAzUBIUncUh6baURc0
04Vl2t/YjMENAgO5cnbc0TEhNqgFx8tUAeHhtvUwxqDD8qQcy0y3maLV7OMlwLCLA/YxgoNg
62nGLpBWsl0csPqyvn7tYcBZgWfukbQDbKCpIi+DiYE/8XDkVPTPHn4HrWQsT046JrMFe4zC
HhZhDvYwUhU25MkFx2t9hgOoTMDCxcskEmSQhOBqC7ECCYRHb3AxhxvbvzC2pxU+RYYWGzj2
KTgaHy7B2fz++n1PHhxXENP2nmYgAezVoGieAInBKuCTGYjI1tErMCJBtesSjiMLbwcAxptw
zJncQANwE0QEZydRnUTRBSFmFz1tIh2c1ikWBw06BRbG0YEtZrSF4kO+qE7OIsmA6DL/ao4W
umOMPnof2QZnjELBcz7GAmMvJZ5SeXaIx1xN//N5saufgu9Ozb9uN19Wzx0n6TQuYjcqRlTO
re5IkkYeo7zjKhYF0OSMYg1BjUbH/XVLFTpO9xjpqkunI4NloOFgrByucJkhUs/tdXAr1B38
EozsOytACfg6t4GE+3yOIxq4mbwq0lmba9FEeOyaipYU2jqFgfnxWrdtqTQtSVKncCeyMdKh
SKe/p+0Z7CrESLPr6ys/V4n84+38AtdFSplRIcMxba5anEyYCyOEanqh70R/eP/xnR8++3g1
/3h1YQNJzm9vLu3AHsCFAfQtv7m7NEDIpjLj0o/AzMdrPzSd0w6xm9yktzcXqBNdBMPerz9c
Wnqa65sBi+XbzbLe7TbbI5e1BKnjoVaDict0pLLkgWiuOMsxwNsF3d782R+EjUBXZgqYuNue
W0AiQKr3xucM/CXoklPNg0VCQ5WVqb2FN3dX/W1G9WJ/2NYd58Qej5WQLAyLyjjr1nPH7G77
Oke6xYSg6EYeTxrRwn+HNsoLEaJsv4hoh0pu5leehSbXDY6OZWTu37X3m7oYPzgRozKKROGd
pTGT0aBkKTFRCM1WjhMhfwvD8AcBixKwFdwCjp3vCIRT7wbYiuOg2p5ak84qtt7yOntN83LA
+KMDRiZfXzfbfcdP5bKJm+qj8qK9KsAjvG87VFjvVl/Xs8W2DgAN3GH4RZ+mcvwI7WL99LpZ
rQfTg6ljQwOeeTnrRqfaDnmLuY/4DJxZb1LGSeyiGudS3Z9TNaCO0twMLO9j+1QlYDSwgo6j
NViUh/AI7sZchOeZoAXEcXsOaLnxCGgEvfOCbv293vlBMDt1feLH++s2t7nIYlxgbJj0HEAk
3DSGW0v1CzaSAy3sYuzI+f9oFGqRCH50U9EuElSo52zK5lFWTcEn79v31i203AxWaVyOhUlG
ZxS4aQam6DYA8UNh72c68NcxuNW1gsDkHoFt4Ebp2thNOxhKkbKDUgGaPAHXJDfWegIBqO8/
2n8tpvoXwtnqlKqJnYCnJlNwedAjbxuXp/MAoRGD3T9jOTUUhrjB37bSeNLZFE8Ey6xcJen2
mCtFxygfRyUVVT5ayIIVyUMllRVsnVsnClwF5mJpm3hc5tVIZDxOWUFxZ+P62uzrKeLRDg/1
oMh2kSffaVNH6AFWjyAcVBGK4v76uq0ubFiBovFMqg7bSUuuWCS56EQJUNOgP00Llwb4j2mV
0Qb+2rxifr8lDdF5VlHnSho2pqIZj8i3VaFA34Pff5ZY5/YRMNbVTx09w3L0UzGBbqg4JE9D
dBY6eeK5zBu5QSv5ArUgRnooJV+C3nvEjAZcjKP7BrwS5Ju/6m2QLtaLr/VLvT5pHYRF2/r/
DvV6+SPYLReNU9cxPsAZ+UQl0AL59Fz3kb25usYXEKE+4WFoN0/EUHlFz5sF5uACqw6D+uXw
fCzMsHC2D57rxQ7oua7P0ODlAE2faxjnuV7u66cjermrt7vXxbIOPq/Wi+2PwMao9x2LbwTi
KDU2XBKFuUfHN0iaFzL35LkcBgrMC1EGVV7snUpNz89BGPRJ76wHS9+XE31bjH6+iS5oQt8i
j6nULnLxBROacTExpOWoGzXGO2Bl1YW5wT/06TCBKY0/pDmyclj/uQIqhtvVny6bcC77WC2b
5kANt166TIITLeQiQjE1ae4JDYGkzUKGMSmffWOHjyR48axwoW16r9GsShQLPYtw0X5MOVKE
bq11VKItLafezVgEMS08QROHgBK9GQatZ58jjmVP8QMc3FRqRU94SvmjRyOmkgtKgraxUFId
qyjOywIPRMdwgmHjhJA2+pNlgu7lLXiqzagaSz0CnqNzOVMxB0rZqh78m066GEojh6YVdu1q
CxVhdsZ4lCNAURIYMIDbAzSqvQVqjzdRoz/osVCqo/XSHqoTWlKRrSIppnCCPdMLQEDgopfr
7kQDsDCsSSzYfEG/Gq1pGhAlm6ai786kq92SohQwdfqAi6aTrxlPlC7hCuEm+mx05kifa4eC
syqMpmMe/IZcvhDAiCnl+jlI9fGWz98Pupn678UukOvdfnt4sZnO3Tdw8J6C/Xax3uFQASjT
OniCk1i94q8n7fW8r7eLIMrHLPiy2r78hX7h0+avNWi9p8BVugW/olZegecWyBv+27GrXO/B
qUtBPf13sK2fbZ3jrnvyZxS8LE4mHmGay4honqqcaD0PFG9Ar/qAfLF9oqbx4m9eT6EXvYcd
tMyS4FeudPpbX8Dj+k7DnanDYzodz+eJjSF4gSwqj3JPeSpHEK1XPHa+StQEzca1bLi+RZaT
y6glumydxDO2hd3Cuua8Xg/74VDn/EmWl0NWjoEWlpvkWxVgl64BgAVWtPxmqSDvBgeWXoAp
taXusjG0vw8aAISPDzTxwXB54Kah+huVNFVknsqmlo1WRPHsUvbdcPjvMXXmMkkeevM6Stxw
kgCeQiad06FgDUunl6zp9jwfriU3ebB83iy/9y+9WC8+g9AApxiZFsvZwKqaqWKCfrJ1jcCG
SXP0i/YbGK8O9t/qYPH0tEJbafHsRt296USeZMZNQcUXmlwPZkFLbUBCYrSoijuZYWjx3Z8Z
HQ7P1QwuJJt6qoosFLWbxw+0cEyrJDRXxjNfCZuJRZEy2t2aMcPjUFHZYQ22BmXzQjuBPeJg
3FDoCBgQOj0871dfDuul9WsaMfB0kopnhReF1laktSEAMZCTgKUh5txzKc5YccJDmqntNIXS
IHO98Fi+v7u5Bk/C4zvFBo0KLfmtd4iJSHOP4Yzg1Ly//fi7F5ynH+aebAeCdfruypOHGc3f
XV1dPkeM7HrYB8FGViy9vX03r4zm7MIpmtQjgi3w9+T9+zl9aSycv7/98Ps/IHy89SC4ogjj
MeFTEUpGvTBwLtZ28fpttSQD5GGRDvAZz4Nf2eFptQF9f0q1/DZ4ZuGQ0zBIVp+36JlvNwdw
/Lt6hnurCEJMasgRIfNdGGG7eAGf//DlCyiwcKjAIvqgsO4gscYwXAjqSM4uxZjZFxG0xFdl
RnkTJcgNFXMJKzcmERjdl6xVGYLwwSOR0jo2TYo95h0jouwKHBfygDZrgz51TSlsz7/92OFr
mSBZ/EDNPhQrOBsoDtpdV7mFz7mQUxIDoWXi0YMIHLNw7BHjBhxNXzW/G9VrHJQzz8VIPddR
gM8oPUUemcBa/ZCeyZV1yZEEClLulAgZPyb2NS/KVozTggbULUA2Ah93SrsNVtAz7XHgU0b4
2S5GkjJwnskA0EPGsbzLE58r56HUua8Y2sZYndE8nHO62sJsFCdhN7AN0p7Ya3zE5Xaz23zZ
B/GP13r7n2nw9VCDp0HIGBd/QOGK6StfkGbci/uerRGVhJH0CBEeg5MHPi/IRqzepiIXPJmg
WZooNSn7uQ+AYQQInON2ptsWzDdlfm4jm5cXUOXcWm9WMP212X7viDkYKNYhzY8I/KQKSfvN
5+mqbE4HjVoo+Zx+yNNGATVNVxbEMyyp6RfduH3YvenNYdsxVo43G4uuXfSk0zKIAtmUugXp
/EO31PiMYw2WXHrKceNmAJ7+A0JqSnqbJwyT0o8jxGmRhhZ0KZPJSM0Hp1TUL5t9jT4wdV8w
Dmcw7MCHHV9fdl/JPnmqjzfNr4lmsiAcVpjn16aoSAF3flu9/hbsXuvl6sspoHrSHezlefMV
mvWG99XKaLtZPC03Lz1YawX8GKQbrGH1Jp1TY346LJ5hSP+YZTaX/lgQTtklje08x7q1v31j
zrEuel5NPS9ickzRTvv5kDNPzI3XSLSJNNqp9VAtnw0tGgycLYFIw+gCQLqPxPAajUEBYWou
K7oZTweZ3lbS0DXaaZVNuy+xZI4Vxj7da/0yWxNbqMTnnEfpkKnRymg/djqL7CZY7DNDwG2q
JipjaBfceLHQ+wVxV918yFL0tD2lG20sHM/vYXJGi9eUe4xuNtSWbP203ayeOvVGWVgoSbs+
IaOdmswbZdGGbpeZAalpaDVow5EkwBOg0FLRC9OJTKlISnSMdYbDi3fKncCeUs8Zj5XCWsYj
KhGR/bpdtCKqnQBktHquA8dm3Yl186KJcToCIOZoqwGarXDwBgxtuSti+GwQGEFkvHjIve8y
Ip0pIyNPUO0CTDpY5X0WFrELvT+VytCUtxBu6HPBDE6k7ypPzizCzLoH1iQiemBHlcXyW89J
04PaCic5dvXhaWNf+RNkRQ3qm97CQFgmYeF5pon5d18uEB/P0ZaRK6OpvBaq+wF84BnAZi+Q
j9xrHhopS4aH1tR6fVssv7v0vW193a7W++82GPj0UoPpMCh+gB9aWbYd23fJx/qj+99PbwzA
z8F6sQHG3cmqfQUC/Me+ogXKLb/v7IRL176l3BCXfMTqH/q+ZbbyBG54BqhgWXNwsD1v9Rxq
WmrjHtARuiwq8HsBONr99dXNXVtIFjKvmE4r74M6LAC3MwAW7XJmwOUYHEpHyvPuz5XbzbKL
qdqI0sKxwESxdjvrpEltHy3sWwfkmhSDlDS39pDcsWLB7qXV2JKemWCTY8WTx8BFIwJ4tZvM
6wx1KoBzDh+YvtsfQVh/Pnz92is0secEBpTItE8+uiER0T5K9B93rqRWmU8Qu2HU6A84G++z
pWb5oI0SOIfh6R8hF2Zwb7JK7RMHDmvqS5Qg0BWwFWIMR3Ipk9+UaWGl26UFxb28a1NTAdQI
EnDdDq/u8saL9dee9R7ZSrwyh5GGD7Va0yAQBGHmnpaTSLNPZFC9RcEM2Ap4VvVULQXH4sZS
tApVLRAdM1Wa+0G9plfoOLCjGNayDKRJ7yhxhokQOVVohkd55vHg193ram2zK/8TvBz29d81
/FLvl2/evPltKBYp57pPbHwOfbGw4xh6SmCFF9Aaa8U+OzxW+NHDWssHqG4wNd+vdThTdubW
RpYLtuM0zadw6EFQQOE3B8pMC4GlcxcSes1ddHf50k59nyVoRIr8Jwx9SZRY20r6Xig7HF7A
XjKsQx2qb/z+Ai0TC4VvSj3O6D/SAz/NYJ+IXsT4V8P46WU/QfFJu21eOIBZ85WRqvBrlONB
VqIoVAG39Q+nvjw2LX4ahsRpC/KozJwKtFvov2uN3BeWUvfoDWwNVfQfyDc1/a6/LcMfPAVt
OrpR+gVNp0e9Q7rjh0bAbjL1bt+jvC3Nsm/EtS/3YFG80NH5e1NY0ugn7ggrkPxwdBmLqa2e
voTmJM77u8tX3y45FnNvZZvbExhm2bgp1qPvlMWbAKLxuKAWwX6IIvLDR9L4XE0LL0uPR26h
BWaljPeZjNurL3FloZF0D2gvrCD0fpwEVL73nK19k7mvAQBjFqXf59QszX1PK1uV8eVIswyL
+jPfRzosBhlLapJWriqkktqVOf5/H1ewmzAMQ/+F+2CANHHZoU3CFK20KA1i3aWHDWk7bJNg
HPb3s50SaGP3hmQ3pInr2LHfM3p457v1aBdyGbbzIzyodQPnxd6WOo3UxKS4Oxq4BoeLCMxf
FbAJj5MvyEtn7+ik7+Dn8WdaT5I/ypxvVwNASkwUsAmeug/jkDTa7PyNudLxcDpNP3osY6CM
NcjEa9SHt/Px8/ePS62eTSNkrUbtnPUNeCRT03UdQYVHdfmkBB3ehbeC1lZV24a2VGUDdH+i
JsUDHoIV1EE8S9qjGxc5ePzrq2Q3XZlDaZ+yDW9d+MAvt2UGkXPqKkIol1al43Meu35dPcTU
k71zUpcFEDjDXeFdqWAR19hsiOvAqxSmFKSIEbNVD5YTaTbUZou0gBTCOdPrXVVOtUpZz5sB
SOcPkqT183tted+KYushZmA2EWTLxWAOy8UYvqRTKKwyebNiHg0SvkzUqWRuLxXpg4bkhEEq
Dsw3ohQ2pyGF/n2nVsJlmkbyFCJWC4w2Y1DDEBEL6xa1Xl7hq+AHCKI2V1yj8cWq2G86EY7P
QVZHKpK8qnkirBrN+RaARgcIERVc/cZT0Sb3ADdxl7YOk1FIEocRGZWy+eQyzreLZ3r2BiGe
sCFa80cMcQVW7BEDhrLWvv9CAfbGe0msPwg4siv/A/XKWOGkD2HV6HbhyuyQZigBfPwDPi+l
pmlVAAA=

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
