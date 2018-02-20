Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC596B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 18:38:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y25so5657155pfe.5
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 15:38:55 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id ay9-v6si1882840plb.225.2018.02.20.15.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 15:38:53 -0800 (PST)
Date: Wed, 21 Feb 2018 07:38:11 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 2/3] mm: memcg: plumbing memcg for kmalloc allocations
Message-ID: <201802210751.Zptrc19M%fengguang.wu@intel.com>
References: <20180220194149.242009-3-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Content-Disposition: inline
In-Reply-To: <20180220194149.242009-3-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: kbuild-all@01.org, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Shakeel,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.16-rc2 next-20180220]
[cannot apply to linus/master]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Shakeel-Butt/Directed-kmem-charging/20180221-071026
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   arch/x86/events/core.o: In function `allocate_fake_cpuc':
>> core.c:(.text+0x52b): undefined reference to `__kmalloc_memcg'
   arch/x86/events/core.o: In function `merge_attr':
>> core.c:(.init.text+0x2c): undefined reference to `__kmalloc_memcg'
   arch/x86/events/intel/core.o: In function `intel_pmu_cpu_prepare':
   core.c:(.text+0x1674): undefined reference to `__kmalloc_memcg'
   arch/x86/events/intel/pt.o: In function `pt_init':
>> pt.c:(.init.text+0x125): undefined reference to `__kmalloc_memcg'
   pt.c:(.init.text+0x13c): undefined reference to `__kmalloc_memcg'
   arch/x86/kernel/e820.o:e820.c:(.init.text+0xa5b): more undefined references to `__kmalloc_memcg' follow

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--LZvS9be/3tNcYl/X
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

H4sICIatjFoAAy5jb25maWcAjFxbk9u2kn4/v4LlbG3FD7Hn5smktuYBAkEJEUEyBChp5oUl
a2hbZY00K2kS+99vN0CJt8ZkT1VOInQDxKUvXzca88t/fgnY63H3vDyuV8vN5mfwtdpW++Wx
egq+rDfV/wRhGiSpCUQozQdgjtfb1x8f19d3t8HNh8tPHy5+e36+DKbVflttAr7bfll/fYXu
6932P78AO0+TSI7L25uRNMH6EGx3x+BQHf9Tty/ubsvrq/ufrd/ND5lokxfcyDQpQ8HTUOQN
MS1MVpgySnPFzP27avPl+uo3nNa7EwfL+QT6Re7n/bvlfvXt44+7248rO8uDXUT5VH1xv8/9
4pRPQ5GVusiyNDfNJ7VhfGpyxsWQplTR/LBfVoplZZ6EJaxcl0om93dv0dni/vKWZuCpypj5
13E6bJ3hEiHCUo/LULEyFsnYTJq5jkUicslLqRnSh4TJXMjxxPRXxx7KCZuJMuNlFPKGms+1
UOWCT8YsDEsWj9NcmokajstZLEc5MwLOKGYPvfEnTJc8K8ocaAuKxvhElLFM4Czko2g47KS0
MEVWZiK3Y7BctNZlN+NEEmoEvyKZa1PySZFMPXwZGwuazc1IjkSeMCupWaq1HMWix6ILnQk4
JQ95zhJTTgr4SqbgrCYwZ4rDbh6LLaeJR4NvWKnUZZoZqWBbQtAh2COZjH2coRgVY7s8FoPg
dzQRNLOM2eNDOda+7kWWpyPRIkdyUQqWxw/wu1Side7Z2DBYNwjgTMT6/urUftZQOE0Nmvxx
s/788Xn39LqpDh//q0iYEigFgmnx8UNPVWX+VzlP89ZxjAoZh7B4UYqF+57u6KmZgDDgtkQp
/F9pmMbO1lSNreHboHl6fYGW04h5OhVJCcvRKmsbJ2lKkcxgQ3DmSpr76/OaeA6nbBVSwkm/
e9cYwrqtNEJT9hCOgMUzkWuQpE6/NqFkhUmJzlb0pyCIIi7HjzLrKUVNGQHliibFj20D0KYs
Hn09Uh/hBgjn6bdm1Z54n27n9hYDzpBYeXuWwy7p2yPeEAOCULIiBo1MtUEJvH/363a3rd63
TkQ/6JnMODm2O38Q/zR/KJkBvzEh+QotwAj6jtKqGivA8cK34Pjjk6SC2AeH18+Hn4dj9dxI
6tmUg1ZYvSSsPJD0JJ3TlFxokc+cGVPgblvSDlRwtRwsitOgjknRGcu1QKamjaMb1WkBfcB0
GT4J074RarOEzDC68wz8RIhuImZofR94TKzLavys2aa+r8HxwO4kRr9JRPdasvDPQhuCT6Vo
8HAup4Mw6+dqf6DOYvKIvkOmoeRtmUxSpMgwFqQ8WDJJmYAPxvOxK811m8fhrKz4aJaH78ER
phQst0/B4bg8HoLlarV73R7X26/N3IzkU+cYOU+LxLizPH8Kz9ruZ0MefC7nRaCHqwbehxJo
7eHgJ9hi2AzK3mnH3O6ue/3RRGschdwXHB1wWRyjZVVp4mVyGEiM+QjdDMlmfQfgp+SK1mo5
df/h09cC8KpzOYBNQidXlBMfoToAQ5EgdAM3XkZxoSftRfNxnhaZJqfhRkcfYJnoFSOkohcZ
T8G6zaz/ykPaevEzgEClR0G2MDvhglh6n7sLx1gCtkQmYEx0z1EUMrxsgX3UXRODpHCRWQNk
gXavT8Z1NoUJxczgjBqqE7D2Diow3xLsa07vIcAnBYJV1iaDZnrQkX6TI5qwxKfLAPQACw3V
tWHIZWKmHkkc012666f7AlAqo8I348KIBUkRWerbBzlOWBzRwmIX6KFZo+qh6Qm4R5LCJO2w
WTiTsLT6POg9hTFHLM+l59hBc/g0S2Hf0ZaaNKePborjPyj6E6MselMmUOYseOguvB/ANDOF
0RLwLmkb8du4JBRhX/5h6PLsx1picXnRQTHWRtcxeVbtv+z2z8vtqgrE39UWnAID98DRLYDz
aoy3Z/A6QkAiLK2cKRsokEufKde/tH7DJ/enODWnZV/HbOQhFBRU0nE6as8X+8Pu5mNxQnE+
5TYQqCLuKAFXy0hyC3w8qppGMu45wvbBpI6jdYKnljJR0ilJe5J/FioDQDMSHhlyYRWNBPB7
Np8C0TVoJvoCzoXWvrmJCNYm8VggmOr06DknPF70geCGy5Ges34AIUFE0WPB5EyPNO3Hga41
F4YkgMOgO7hWDLYiyv5HReLSQSLPwdXI5E9hf/fYYMt7LXZ9dsRJmk57REyLwG8jx0VaEAAR
4j4L2WroS2QjwBgbGQF2sZCVYNDC1OEAOTEXlLpsVzmfSCNsLDzEDhCwP0A8gojXei/bozdk
LsYa/G7o8lX1UZcs6+8JLhtanYL3aJM56Kdgzlb2aEouQIIasrZf7Ht3sILQboo8AVQLmyPb
ybu+MSNObMLyEAFUkcEEDRxzDUSoQYjvn+xVXu9CWKi+ONtNbRSxv4uAGR2ai3IxPFInZaVm
kYDAIMN8V2+AutVF7h5amBaeVBBElqWLqk7ZAGLyWnA0piXYGTPY3jEAsywuxjLpmPNWs89g
AIfdNNRzu/GtwKxPgsNNRAe5DjjgdIqYeRzygBtEOk1o9DNk9iRCzATDONghORuYGLfF0rI4
0YhyCPD7bEQQ5DEpCUa/os7eYSKtry5pWJ9WJji6mVbSOA2LGMwdGl4RoxzHhO2wFNDnVA0T
ncNMco9BLMBPkHar2+uuKwFp9nCySibuyE/zWZgbndXAVPKosCaHihdikBhAqXw6BxVvzTeF
4AugZp0ovR4Q2MnUNwIBMSyEzI2Di6I3fKad9AxXbc+dxpjIk9oAhMWnFFE+pxGzj5nCHQOH
YMCzmFan9jWDl9Tv7gTIw5NNHnRp0m5W/0zNMe1aJJ2Y6dQ2CB9cfpSns98+Lw/VU/DdQcuX
/e7LetPJLZzHR+7yhIE6SRlnnWrf6nzvRKAGtbK4GMNoRJr3ly1w79SF2NaTIhkw1WBwU/Aa
7XWN0JEQ3WxyHD6UgS0oEmTq5rBqulUDR3+LRvad5+DMfZ3bxG7vbpadmRRdfq7mPQ40HH8V
osDUBizCZs38LPmcYrDidIpAypGI8F/oOesMYBM6wuY+dgMrKxfZfreqDofdPjj+fHG5py/V
8vi6rw7tK8BHVPuwm75t0Lii8xh4CxEJBjAC/C2aaT8XZgdPrJhdp1nHYEwi6TFcCFdTPBna
rEFIA/oY0vEEzkEsDFguvDZ6K0Cvb1ZkLt/K78CJG+eaSouyPBHt5AGQDsTF4AzHBX2nABZy
lKbGXcY0ynRzd0uH0J/eIBhNR35IU2pBqeatvdJtOMG4G1koKemBzuS36fTWnqg3NHXqWdj0
d0/7Hd3O80KntJAo64yEJ45Uc5kAKsm4ZyI1+ZpOmSgRM8+4YwHKOl5cvkEtY9qLKf6Qy4V3
v2eS8euSvpSxRM/eoTXx9EJz5tWM2jF4agWsImA2sb4A1hMZmftPbZb4skfrDJ+BSwIzQacy
kQHtpWWyuSJdtJKMSAYF6DbUUP72pt+czrotSiZSFcqClghCuPihO28bhnETK93JFMBUMH5D
ZCxiQL0UooIRwVc4A9XC6nWzPd9OlcWJwlRIsIMKsSIfEizWVcIwcqxCcdfemKYMgl6b+SAP
O1QUOkzsfbsGt39evxAqM4M449Q+S2NALCyns901l1facBMySds0e2hdOXH+rpVQe95t18fd
3kGg5qutyBb2GAz43LMJVmAFQNsHQKYeu+slmBREfEQ7VHlHA1z8YC7QH0Ry4bthALABUgda
5t8X7V8PnJ+kUp9JipdYPTdUN93QEV9Nvb2hEm8zpbMYnOR15/aqaUVo7tlQx3JFf7Qh/+sI
l9S8bK1ICqGIMPcXP/iF+1/PDDHK/rSTwyXYqPwh6yeBIkAWjsqIGhObMfCTrQE5XUsjvGtZ
CxmjHMYnsIHXroW4vzgHJW/1PU1KsaSwuY4Gy5xn5GjEouvO3dFKa+Ndv1bephkOQjjTDqVd
qC3UqAu0O831oIO85ikWGRdZb8dCqTkEqe2BuzFlDaxcPUnS05jzpFFUMmOnYI3bTS8Zzv2J
Z4zhWBjmpfHW0M1kbjDOGxWdQH2qFcF8Kmyw0b+77Q7z+5uLP25bdoVIavgDYJeWNBMIq+cs
o/S+XUg17Wg/jwVLrLemEz6eaOExS1M6cf44Kmjs9KiH9xankKA+flu2dEpyd1yNyK2XA5Hz
BBXgRkagrxPFPJca1i4ioChHMsXKoDwvsv6pd0w0VmJgLDu/v22JizI5bXjtUbgskXcCsAX+
KMtFNwC8aZY61Uhb6cfy8uKCyiY+llefLjpK81hed1l7o9DD3MMw/QBpkmMdA31/JxaCOmnU
JsnByMFR5micL/u2OReYrrV537f622sU6H/V615fbc1CTV9hchXawH/kk18wrHiPEIeGumN0
8GP3T7UPAH4sv1bP1fZoA27GMxnsXrDsthN018k02rbQkqIjOfgmiH8Q7av/fa22q5/BYbXc
9BCPBbW5+IvsKZ82VZ/ZWwJjBRlNhj7z4XViFotwMPjo9XBadPBrxmVQHVcf3neQGKdAJrTa
Kt9Y2Co9bDtV9PDlU4XADliqYLXbHve7zcbV+Ly87PYwUccXVof11+18ubesAd/Bf+guC7aL
7dPLbr099uYE/jm0jvat/CmVsHJFuvVlTruDJ5OAEkqS0thTugaiTceJiTCfPl3QEWbG0U36
Dc+DjkaD0xM/qtXrcfl5U9lK88CC6uMh+BiI59fNciDLI3CyymA6nPxQTdY8lxnlJl0OOC06
Gc+6Eza/NaiSnrwHRrl4tURFZc4WXPdrLetknkx7Xgb2d7BFYfX3GoQx3K//dlf1TaHqelU3
B+lQ7Qt3DT8RceaLvsTMqMyTLgfzmIQM8/S+oMoOH8lczVnuLo3p04/moGgs9EwCPfLcViNR
+9iaK1YghLmceRdjGcQs9yQIHQNmBethwNBDgE4vD6S1lVajHf6pJBAsFHxWcjIr3ebCmypP
TSaSZ0WMhd0jCVBRim79Bei7rQcPYZ+jiEjAohl8spLSEQJl6DNJI2Ku7koIC/3PZf2AAOs3
Ds3Ju6bBDJKZEn3zp9aHFTUtOGb1gNlucnKAouJUYw4XAVB/Y5szypknAwiaWuZG0zaMX5HT
FwKORrVMfDMdSyn/uOaL20E3U/1YHgK5PRz3r8+2sObwDRzCU3DcL7cHHCoAP1kFT7AT6xf8
z9PesM2x2i+DKBszsH3753/Qjzzt/tludsunwBW/B7+iw13vK/jEFX9/6iq3x2oTgAUJ/jvY
Vxv7UKfnmxoWlAxnJU40zWVENM/SjGhtBprsDkcvkS/3T9RnvPy7l/OVgT7CCgLVoJlfearV
+77Jw/mdh2tOh088OGsR2zskL5FFxckSpJ4kCLL1irMbFaI+0DbyMjzXCGuuZa0HrYM6e2gt
EfR1YmZs812UKMYBNqR6Uk9/WAksty+vx+EHG7CQZMVQBSZwhlYK5cc0wC5dGImlzP8/q2FZ
OwUHTAlS6zgoy3IFikBZCWPohB5YW1/dIJCmPhrOCnA7upoesmr2JVOydPWcnquW+VsBVjLz
maSM3/1+ffujHGeewsYETJaXCDMau8jRn0o1HP7xwHmI6nj/+tPJyRUnxcNT/Kwz+oJAZ4om
TDTdnmVDmc1MFqw2u9X3vikTW4sPIfBCVcRIB2ASvvjBWMzuCGAVlWFl3nEH41XB8VsVLJ+e
1oiJlhs36uFDB3/LhJucjr/wGHxKP/dgX0zulmzmKfK1VAznaYDp6HjTG9MCP5n7qtrNROSK
0es4vbig0lF61H6E1hykpqorRxzgB8U+6iVnnM9/3RzXX163K9z9kw16OpvyxopFoYV8tIlD
Yp7qUtCSODGITSAQv/Z2nwqVeRApkpW5vf7Dc28FZK18cQ4bLT5dXLw9dYzbfdd/QDayZOr6
+tMCr5JY6LlORUblsQiunsp4oKkSoWSn0oHBAY33y5dv69WB0vywe1/tgArPgl/Z69N6B177
fNH/fvDQ1zGrMIjXn/fL/c9gv3s9AuDpnDr3VgzBp9HXEvbV9o/2y+cq+Pz65Qs4i3DoLCJa
YbHGKLbOKeYhtSVnztmYYXbPEw+kRULdZxSgSOkEUwnSmFhgTC9Zq04P6YN3wth4TvNPeMfx
F3oYJGObRZJPXUCE7dm3nwd8tB3Ey5/oRYd6hl8DQ0l7nTSz9AUXckZyIHXMwrHHdBmIkWjx
xY5FnEmvry3m9Ikp5dEHobQ325cICDJFSH/JVb9KG1g9EIcoQsZPIbnmedF6UmtJgwPMwfqA
qHYbFL+8ub27vKspjaoafF7GtCcqVYwIHl3grxgEe2RGD0t1sKiKXm6xCKXOfI9/Co9JsVcI
BKDsMMgUziEpBnNV69V+d9h9OQaTny/V/rdZ8PW1gnCBMDEurEbL571TAD0cS08BqL05q0tr
qLi7ZWkgahNnXt9bkThmSbp4u1pnMj9VVg0BrEUseve673i50xziqc55Ke+uPrVqGaFVzAzR
OorDc2tznAYmCYDF84Rh4jBhydW/MChT0LUYZw6j6Pd1QtUMoH+egETGo5QOt2WqVOH1RXn1
vDtWGApSpgsTNAajbz7s+PJ8+Er2yZQ+yarflM9lPrzU1/CdX7V9zhikW4hN1i/vg8NLtVp/
OWfazsaXPW92X6FZ73jfLo/2EMGvds8Ubf1BLaj2v16XG+jS79PMukgW0p/ygKmXZpizX2Bl
5g/fmAt8zrIoZ55nlZnVr35Gv5GKhfFiHHtDTIuD51Sy+dDlY35oBYcwDJkZ6P4YrLViizLJ
2/WhJ8rsupSemzqZYcW3zy1ZmG6fguRp7AsDIzWUSPSx7eewg0ShzwkDii6nacLQZV55uTDW
yRasvLpLFMZVtJPscOF4/oCDey4CFR8iEKLchTLtORt6MbZ92u/WT202AHh5KmloHjLPzYM3
5NeGbneXmYYGmzbrRhI8EauWHvumY6l6suTw6imlFw4VT4SeTPkpmQ5r9d3ThuCxynxEq2zI
wxHzFb2m41icP0EkMr/ul61EZCdvF+HdjJPslncLXY0dhOKtx2StnayfvzJOx6digS4B2Fxh
hi8HZ4vHkcOHCGCEuk7GV0ERafv8yJNNeoMmHa30viGO2Bu9/ypSQ0uZpXBD7wteE0T6pvRc
zERYneihpQDeAPf1yPWl5upbL2LSg6oLp+yH6vVpZ+/jmiNvbAd4Y9/nLY1PZBzmgj4JfNDg
u3DCl9Y0/HJ/6OZtaulFk+5fICWeAex1AUqZew5KMyXxcEvrx7Xflqvv3b+tYP88FHivKGZj
3QofbK+X/Xp7/G7zWE/PFYCYBuA3E9apFfqx/UM5p4Kd+9/PBdWga1hhNuC4aRsKvO/CUAGA
8OBvzbgj3T2/wCn/Zv9eBIjH6vvBzmvl2vdU7OGGxVonWqlt0VkJJgb/XleWCw4htedluGNV
hf2DSoJ8neGK33G0+8uLq9bq8PFLVjKtSu8jbXyWYb/ANO0higRU6f8auZbetmEY/Fdy3GEY
2vWyq+04qRZbdi2naXsJtiEoelhRdA2w/vvxIT8kk+puW8n4IVE0RX3fh82aOm8ULjnj+A42
eegYxtUQliUeeTp+syWX2jFpFYOvxj6dvCQiJx7WxiptQv80DcmtlNluAFwpNTuWSRDy4SFc
cCmmHw2BW0Ot/vq+Wp9+nh8fY7QrjhNRH5yWhCOVKX2428a4xmrZni/TNUTajqM68mpy5Aar
HEf/kvCxrWC0lnM0WBJ3YPbg3mm5h71uJRTe2AHyPrBjiYCTgSFxeQ/IRDWP9KvS0+I3YlOR
/I/0MoM59dLX0cmtxylAXKwq2A6fXziNXP94fgw3Mc2mj/i8ckpf8n6Vx0EjfAEsS8SITocb
sRM+izkLCwFWWRNVIJI9hsSyEXfHCCpZ4NPUNMlmjh5UhFvkv2jI8Q67smwlHR4c8mlVrj79
eXl6phOPz6vf57fT3xP8A0FRX0JYlJ9LobERhxfKhSRBFYcDO6EOw6HNlJqbfanWS2SArrlN
l3t0AezUJm4yNPMqGLIPngVuQwx4V1YbnTJGN4UwHJllcqiN4+AvpnW3vISkfBHM8ShmtLeu
LJFJljhx9ImKE13qTTW9I5+VzUceLpWNB3J/KkaKDt7F9iYTCikUdpI/KxQNmu7Th/OB/H3i
YSQ9/usy+nyRttWNT+OpReLV046d/lEeBjLWtlD2HgjiFn2GAmfUPlAUS0NBDXKKJQRG67bL
2mvZZ9CjEPU6QiPR7iWxBm+umXwMdSPsKiMXj4blZ2DZiVhTwf+wHmjNs4ocF/o0ANMo6jMb
iGPIc4+qADWHDl4/7o3PO2JqeFGlYlmFRgaFT6kjq1uZ/Tyx23fbdXD+gP9PlR/73GUWrgzV
A8p3MU171k8b4f3saJuj1YSlyCNd6twSU8Ix7K8Mjr6wsw/FR9445lQosmYM0U8IZ9EJQY9I
Qv2QdvJJrVi548OCHbqqkP9iw4YVFd20uapr0yir0jQsh0una8eLu28XU8ER22AIL2XbniV1
v8pWotJdLWx0szmqeDIou7jRg++X9rERnHQcMZ/L5o84r6aKNluuwqHnMQjPzWRuo7mA747S
jh5Jl8eNkpL39mAs7OR0HnbsiBxsNyK/Tr/Or09v79JWelfeK62Qsth3pr+HDFQ6akmT1EPS
V+sWBapEWj3SQ34e6P5LwHA0S9PTZTPyVWwNFW+xO6fL1d4GhCC/4TEPuhZXbmzW+SQQIFm5
IF7iD/zvRjWnvrNFew9z2tT04ktELrpUpVWsG5hqrwWdG0EnFPH9A7o7MkV/nvSjULyAFAvb
yoRKYUVXHIvC9HIEgPVSJofi7/rLi7WR0fJoNj3UNpr1Sj4+AItMrgeDjKipTE6X05RyC5lk
T7q3XieWkfQCM3z6GFOZfPU1XX3fPaCOfMJ0zIvvYqQ6nLo5SZH/hLk7JhQ6L7gyrbFtldj0
YKGxNh3uZbUuOLrQCb0KVYWyRxmY9VrePpNGsCr46EmLmjGm38Xh7AjrYwKtHkxjdivOzz+m
0YYlhGAAAA==

--LZvS9be/3tNcYl/X--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
