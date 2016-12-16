Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 007916B026C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 11:45:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so196372499pgq.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:45:53 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p33si8495900pld.189.2016.12.16.08.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 08:45:53 -0800 (PST)
Date: Sat, 17 Dec 2016 00:45:37 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/4] oom-reaper: use madvise_dontneed() instead of
 unmap_page_range()
Message-ID: <201612170000.n5uytolj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
In-Reply-To: <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: kbuild-all@01.org, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Kirill,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.9 next-20161216]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/mm-drop-zap_details-ignore_dirty/20161216-231509
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: parisc-allnoconfig (attached as .config)
compiler: hppa-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=parisc 

All errors (new ones prefixed by >>):

   mm/built-in.o: In function `oom_reaper':
>> mm/oom_kill.o:(.text.oom_reaper+0x114): undefined reference to `madvise_dontneed'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--C7zPtVaVf+AK4Oqc
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICJwYVFgAAy5jb25maWcAjVtbb9u6sn5fv0Joz0ML9JJrLzjIA01RFpclUSUpJ+mL4Dpu
azSxA1/WXv33e4aUbckaurtAkUQzpEjO7Zvh6OVfLyO23SyfJpv5dPL4+Dv6MVvMVpPN7CH6
Pn+c/X8Uq6hQNhKxtO+AOZsvtv++f56s5utpdPXu87uzt09P59FotlrMHiO+XHyf/9jC+Ply
8dfLv7gqEjmsS6al4Te/d3/neXX4w1jGR/VQq1tTlYfH+taIvB6KQmjJa1PKIlN8BPSXUcPB
NE/rlJlaZmp4UVeXF9F8HS2Wm2g924TZPly12Rqm3XsG1fCwhN3D9FbIYWr7BM4yOdDMijoW
Gbs/2pPVjIsaNlUq3RpcCBHXcc7qnJXIaMURzQwdORPF0KYHWjm0bJAJeD4Wmbm52D2PRdL8
lkljb168f5x/e/+0fNg+ztbv/68qWC5qLTLBjHj/buoE9GI3dlDJLLYSOMSdn934tYLsXkZD
pwqPeE7b54M0B1qNRFGrojZ5S2CykLYWxRgOHJeSS3tzuV8k18qYmqu8lJm4efHiIJ7mWW2F
sYRgQOgsGwttpCo649qEmlVWEYPhaFiV2TpVxuI53Lx4tVguZq9b05h7M5YlJzXHLzoXudL3
NbMg05TkS1JWxJkgaZURoCPE2lI2Fl43WQW2BeuA/WS7o5f6S7Teflv/Xm9mT4ej3ykekOtS
q4EgdBLNBFSksGY3mZ0/zVZrar70a13CKBVL3rasQiFFhvbkyCQlBTsBZTM16pQ2bR63El5W
7+1k/SvawJKiyeIhWm8mm3U0mU6X28VmvvhxWJuV4BZgQM04V1VhZTHcbUjzKjL93QDLfQ20
9lbgT9Bt2KQlF2yZGRlkIqk4GCw0y1BLc1XQU2ghHKez9+A8uAiQs6gHStFrccZYD2RxQauj
HPlfTrgvw1NwIPzYU3LwrlVpaCVPBR+VShYWBWeVprfgZ0Y7c3PR20QnSG8tG4Exjp2P0DGx
Ac5rVYLSyK+iTpRGrYQfOSu46GzkiM3AL8RsaEw2gyPnArjBPzjRtNyzpzvrAweZySG4kCxT
twcWrzPtd+fgSSSYs6bPZyhsDspUN4ZMM92bxJzkKJWRd4T17BlGMNLc5zSx1CDGEXEgPqwd
xAGxoE6qwBqSyoo7kiJKFdoZHCHLkpi2ENxOgOY8VYA2KJPTx5mCb6ZjvlT083gsYevNpPQh
oohd2AisCt45YFrLriLstpMPRByL+KBIzs+jOtddp9wgpnK2+r5cPU0W01kk/pktwBkycIsc
3SE4be81G+keJiEXNs49tXbuMqRAGG+ZhSA+os80Y1S0Mlk1aGuQydQgOL5OwCUiGKk1BEZF
iwhkYAHgxcyyGsK4TCRnaKsBxVaJzCAChAKp8hwdZ+EIH64GAEuciaP/4lwYE5rE+QPnKlKl
Rv3QCnDHBcXaplqwlowbiAlTFLmsDUtEzfPyjqfDIz1wjEZwFEIN6wUpHbk3hxxhM1Zw8MWh
leYqbuYqBceja2FrFVcZRGBQ41pkiXPKvZUaT3LSARdKrRKY0vbapGHgRkzNSkn570wVENpg
7bdMx+bohQAYuEqFRuV0yBeg74EFYzxwiAT2IZElSUxPjm6ecQOZeUd3PVblavz222QNecsv
b1nPqyVkMB5S9JMB5G/UStQhB+PevJM+Lny3C8rFok81OWK485az8NIg+B1cRmgBLt/IQVd1
BxjByUFgBMJlQxC4kAmhYBuDOzpqZ0M/RSPH3moEKYHBbWIz+hA2wOi/dp2iO/lytZzO1uvl
Ktr8fvag7/tsstmuZut2hvjx7OysPR08OT87y2goBMSLs7MQ6fLEuE933XF7wvl5K9Vy+Sr8
GAoHMeqrUdf75TQAghNx2knJ22lekjEL8QPSJOYlvvdvQuSlBTMoOnqwez5WGbh0pml01XDR
Kvy1Pid3DISL686Jw5PLwKH6WehpbmCaY5yYakTvBHtzAIed4wPYdiwwrtYdv+A9HUTUriqC
q0AI7WfpmmrzHLQ1UW5SKpKVGRheaZ0Kg+sxN5/dv6MIycOxKL0HLxjHurY+uhAvGUtta6vQ
YbYXOTI5wbzLUtEr1jlYNk5+c3X2+UOnLADh37nKUWffHBL7gkNmSsN2njPy+ddSKdrnfR1U
NO756pyb4sQOcnbXlHGcteSDm09ne73H7NZp/w75DLbraPmMFaJ19Krk8k1U8pxL9iYSEGTe
REPD30Tw2+u244aHtDS4DDznrJtpeGfE3qJpR+vn2XT+fT6NHlbzf45wFof4YKSpMx7XmaAP
o4z5jq/3DvHvbLrdTL49zlwJLXL4btN5BSR5SW4xCNPA15MN1zJk1i4mqiqQSfrxuQwcGocs
L64CTqwQtrelePbPHABqvD+sQ30IztA/jpSXaXuflQekqcjKQN4EWaHNy4TGqqBTRcwQWoT8
nps+kToH2CF8Bk3nNLd1plgcWITL/VyCevJkYgF5VB1rOQ5uxjGIsRb0hjwDlrqaaSAc52oc
SLnBz6T3cHCQsyj6hfuiD/gFeK3kofcCdjEpHFEMZ5QkRJRGo3xwUu4IMLf0eaqEcAMuxOVY
Km2yHgyhuql+tmKwe9RbQY4VZWIJII78HkMrnT8WAD1NBcI3eFChAzCa0WkIvyAXIwRgwzxa
b5+fl6tNezmeUn++5HcfesPs7N/JOpKL9Wa1fXLJ3PrnZAWYdLOaLNY4VQSIdBY9wF7nz/jr
zpbYI6R7kygphwy8xurpPzAselj+Z/G4nDxEvpy745WQGj5GueROat76djQD6QDxeKxK4ulh
onS53gSJfLJ6oF4T5F8+7zGf2Uw2syifLCY/Zngi0SuuTP762JXg+vbTHc6ap3Qez+8yB7iD
RJZUOwtTZTDhk7HYBSXDjWy0ryX1PagxEqF8BwPis7gbXptzeN5u+lMdQGJRVn2FS+GMnczl
exXhkI4NGCzS0h6A5YLUYA6KN5mCUrVsalePsfftnYzpIFIV8u7zJ0BK97RJZWLI+H2Yjmtm
GUJa78Z1oDjkb0lkQdcjwKuFijxAGh3RvCghKE0eqcjeLOkTINbeqGK5eOsIaz/cGSshvmaO
imkLQDLguT2P4by4o0NJw8GwAsDqvy0b4oT/A+sf2TQd8htyYrI6K4OTgGYQRcSD6pa5rP1l
Bx2P0ttTJR99+bl7+XZ4L4f/ZV+U8oKTJhSokJuSBoMG1k2v18jeO0vwF8Q7y7KP9PBZc1+6
dBcsu1Geasto+ric/jomiIUDh5BI4NUQJsSAuW6VHmFu4aqlYDF5ieWuzRLeNos2PyFxfniY
I8AC3XSzrt918HEp1dFF0552ex6oNd+Ce2TjQC3ZUQHICFpVPB1vNzM6K01vgzcmqdCQS9Br
ZZansaIKfcYM2sUSb+vLxXy6jsz8cT5dLqLBZPrr+XHiwupB+oaqaA4gNepNN1hBtJ0unw75
AcsHrIPcOeHy8+3jZv59u5iifHaun/A/eRI7hEmfl0W4ZCS/pMvOMHYEaX4A4CI5tx8uP38M
kk1+fUZrAhvcXZ+dhZfmRt8bHpAnkq2sWX55eX1XW8NZTNunY8wDkUyLYZUxG0C6uYgl212m
96t/q8nzT1QEwnBj3fcrjJfRK7Z9mC8BrOwLVK97/QuOOVlNnmbRt+337xBM4z5ATWirw2Jo
5sAwJpLEyg8BeMhcHwDtu1RVUDdmFViDSrmsIQrZTAAQhgMqDmUSpPd6D/DhvgSa8g6gqbpm
4naIz1wgfOjCNXxe/vy9xp6RKJv8RpTRV3d8G3g0OstUpaPfcSHHNP4A6pDFw4D/QXKVlRJr
LDTDLS2XPA8op8jNcdWqlRTfYi2AfpO/VZADCaK4J0SlwbLBN7d6Wyze0zPTKQ7hw5RbZQJ4
Cul4aQJCD9JdftmTIlCiOV4nfZ8cqS6OgWifIJYKT6rHve6MfXTGuY+UA6Nw4DHGusCo8nGy
wUrJEa23kticX3z6cHKxwHJ9Tnu6Nss17WhbLB8+XdcJy2UgwrU4P17RzUcHlourMxr77FiM
HZ1/tOzTSab86pP9w+6R5fL6jyzXn0+zmPzDxR82Nfhy9ensNIsur3kg6OxYxpdnF304Dmic
l9WRMhyNbKofu+Cdyhiw/wKzzoAOQbpGVEl8hStngyrZ1SU78OG+4HhXR7tnVt3F0pShxocq
EOxcgdgnqP21jOcrWAW1ARwmFbiw7rRN/WS6Wq6X3zdR+vt5tno7jn5sZ2s6h4F84+gytZuE
muf5wiHXIyPl7qFZblc0wMHiflaXMpCipL4VoOb5HxhyW9F6teewOd2yI/KGAXw57eaZzAaK
7m+QKs+rIMjQs6flZoalDdI/iVxZrA3x/sDnp/WPnjsExlfGdTBFagHp+vz59QF2HpVH9rjU
LEnFNlVxJ8NFLnhXHTiOMkffn2gRKK/d2SDqc31x9DkGtL68pe4/mM7roeTuFqHQ7dtTWeKd
QijAu9wEQGthtcpCGWmS9+WBmKTdPtYrp4ZAC6Zn5R2rLz4VOeaOgSuJNhfAFFqTIZGoR6pg
jiP8RsyyOKOLCDnvI7Z2P8kTJEeQmFIeQLO+22GLh9Vy/tCx5yLWStIZRxEszBhLPwekAd7B
pr03u6pnB3uDfHprdly9oXjD4iXZBeWm6aVinE40xR0aObC568XjKuFhHuwPQI4jf9l6UaGs
TGjxxSdo0tPqYEtZwk6M/lIpS1/tOQq39K6xgS8xV3XgwiXBrpEATUGsgjB3RPZnPpn+PMqJ
TO9O0qvnerZ9WLp7MUJo6D1Dr3c0nsos1oJ2SCOhi9BFEjbe0Vl3BQlGNnB3/SSD/wF6EpgA
L9mclviGJpqpyPqH1jSA/ZxMf/kmFff0eQVI/ZcDyg9PMwgbB0RyWJBRTimHrhV8d39883F/
HQvZCLYu9DiuWprpbqIQ26Ra0fCeL5+eQU5vXa8uCHj6a+3WNfXPVxRY8tPi/TttdK7vob5l
ugDWUgsOaW+gMdCz5pWxvkeViByJxuZ2nO3m/OyitTtjtSxrZvI62CuJfTDuDczQ3qoqwBiw
7pEPVKBV0DWIqNvi5HVgQl4/CLyMNH5n7SywkYtw/QeoXDkWxGilPmLyx6qKjMpBXdZ/y/C2
1B2a6/iFFXQ7eFqUUztSmsOxCzbaNSUEkBZGdTCL7tVdZyq0WbHves8BYa1+R/Hs2/bHj6PO
LXfWAEdEYUKdGX5KZOw1KnSngS0aVYQ8up9GDf6G8z11jes7HioT8hyeaxy6vEBi820B9oJR
SoJ3VK13oQdOfJcytZQd+dSS06N71OZ2H847ygDab5+9iaeTxY+OXWMErEqYpd+X2HoFEsGj
Fr6vnmS6/UKWeFvyKUBpQKsVfW/XoddjllXi5qxLRPyvKnvT60oKuiVP9vIURdz3N0fHiG8Y
CVFSORQe40GDo1frJpVav4metpvZvzP4ZbaZvnv37nXfce4+czqlMtidfbK9gFmVo+FlsMIT
bA2owYZOcCVZgjEgcNOHAAmkbvGa/ThUtJPK5punEy8debM6wQH/QY8HKnC526xdBhbRuAD5
Jw5zyvQd7JKhBmrPw7WIRWElIyI7fk5C+zANNhr82sSUTBv/KckpH/xHQbgJsFf8JMf/NM0f
Pmn5YvoVx6NzAnv34UKHA8XuvGuhtdJgpn+LcPud75UjedpuM6kKfvj0Qx91Fe6pQ83KlOZp
PhLwRCeQVlszPkTjOVTYDwvsHZpXCvy+CYCUna03R2rh+oFcv7wJXREMDt8TYud2WGgD9zlS
kO59w4ervcXTKoYLSsVdsBPKMSDIKoZNcxdtK45vBIw2UHFxDO7Gme6Ec/SBtHkgBXb0qgqk
qI6qsZPdfdx4Yq/AcmL+OPhhEwTw4Ck6FFH4Lxy40roqg0ptWF5mAae+R26mrgaGFdgAW4S+
3XEchE143YHgn2RsaCi19eaqFS43BDexM7an2GY23a7mm99UOjASweYQXmlp7+sYkhVXygFl
CsSFHS8NpNFUU6bBGUMIx1yaq/LedfRxvEykP204Yu82Eh8RSezqvdBhF6z1BcYxtfu5q74v
LY1CBrJg+p6wBo8r5t9WEwDHq+UW/Ee7nWf/eYrVBYe9J9ifhqvvf8FScolFznaX9f6TUtVp
K9aQbHNpaYkA9Zy+hMBx9vwslrQ5I1laiCshauAbbqDQ99qZHLhRoQ94OX2dAgTwgSLUHX3o
Wd59LtWcEu1zXcfL5cVpn3r3FRSDnsCT6gH/m1RwgyJr98z7R2jAxw3zBq84+rLdef2OhJWO
AxuKYxp5uK+Og18ANq31IWKw4Xx/H21c67XsuK//Ahu/43egQAAA

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
