Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 17E3A6B0006
	for <linux-mm@kvack.org>; Sat, 19 Jan 2013 03:02:25 -0500 (EST)
Date: Sat, 19 Jan 2013 02:52:26 -0500
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
Message-ID: <20130119075226.GA1261@gchen.bj.intel.com>
References: <50F79422.6090405@zytor.com>
 <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>
 <50F85ED5.3010003@jp.fujitsu.com>
 <50F8E63F.5040401@jp.fujitsu.com>
 <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com>
 <50F8FBE9.6040501@jp.fujitsu.com>
 <50F902F6.5010605@cn.fujitsu.com>
 <1358501031.22331.10.camel@liguang.fnst.cn.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F1C988096@ORSMSX108.amr.corp.intel.com>
 <50F9F186.5050204@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/9DWx/yDrRhgMJTb"
Content-Disposition: inline
In-Reply-To: <50F9F186.5050204@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, li guang <lig.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "rob@landley.net" <rob@landley.net>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 19, 2013 at 09:06:14AM +0800, Jiang Liu wrote:
> Date: Sat, 19 Jan 2013 09:06:14 +0800
> From: Jiang Liu <jiang.liu@huawei.com>
> To: "Luck, Tony" <tony.luck@intel.com>
> CC: li guang <lig.fnst@cn.fujitsu.com>, Tang Chen
>  <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu
>  <isimatu.yasuaki@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, KOSA=
KI
>  Motohiro <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org"
>  <akpm@linux-foundation.org>, "wujianguo@huawei.com"
>  <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>,
>  "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com"
>  <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>,
>  "rob@landley.net" <rob@landley.net>, "minchan.kim@gmail.com"
>  <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>,
>  "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com"
>  <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au"
>  <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>,
>  "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>,
>  "glommer@parallels.com" <glommer@parallels.com>,
>  "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
>  "linux-mm@kvack.org" <linux-mm@kvack.org>
> Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
> User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:9.0) Gecko/20111222
>  Thunderbird/9.0.1
>=20
> On 2013-1-19 2:29, Luck, Tony wrote:
> >> kernel absolutely should not care much about SMBIOS(DMI info),
> >> AFAIK, every BIOS vendor did not fill accurate info in SMBIOS,
> >> mostly only on demand when OEMs required SMBIOS to report some
> >> specific info.
> >> furthermore, SMBIOS is so old and benifit nobody(in my personal
> >> opinion), so maybe let's forget it.
> >=20
> > The "not having right information" flaw could be fixed by OEMs selling
> > systems on which it is important for system functionality that it be ri=
ght.
> > They could use monetary incentives, contractual obligations, or sharp
> > pointy sticks to make their BIOS vendor get the table right.
> >=20
> > BUT there is a bigger flaw - SMBIOS is a static table with no way to
> > update it in response to hotplug events.  So it could in theory have the
> > right information at boot time ... there is no possible way for it to be
> > right as soon as somebody adds, removes or replaces hardware.
>=20
> SMBIOS plays an important role when we are trying to do hardware fault
> management, because OS needs information from SMBIOS to physically
> identify a component/FRU. I also remember there were efforts to extend
> SMBIOS specification to dynamically update the SMBIOS table when hotplug
> happens.

Really, how to do it? Can you describe it clearly. BTW, if my understanding
is right, new Platform Memory Topology Table (PMTT) in ACPI5 should be for
this purpose but it doesn't exist in the older system so I want to know if
there is a workaround for older platform.

>=20
> Regards!
> Gerry
>=20
> >=20
> > -Tony
>=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--/9DWx/yDrRhgMJTb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ+lC6AAoJEI01n1+kOSLHNzsP/iN416onnOapjuR3Xv/8OzZZ
Fsv+AUlJyL1vBAVO29C7EfvO+bFBAnx8njMP5zDLmdrd7mRcgj7yXeya0jnDSlJI
iz0n8nYRa/lebQBonLh3aimhQ4v7o5VCloYPDXjXQFi+pR7NHvNhrbf3m/Zq6Lrq
I7TlNjZWfd5DiyxJn9xic6oiU0+H/U2Qwy/k/HJUMenwjHyzI6EEqwVKeI+nYrAW
fAl1aENzaONdrEPoO6JoMblZkglTeMAUzYtLjZAjWMzg9kWnm8EOcnE5PZgGdRiJ
cbIWLsntxI7T3s0XXN0duUbeiDHWu4H1mBgzAlwLFlvsvs4ckWX2+pIi+dLLcI1j
I2SZemf08DOL904CBDt6pFpqVvmGi5NFq7AFzt1VgTUzSAauEnqB2kZdX02FOf9R
qnbgJSjEtRJr9oDBH4Ume3maVImYnrf10YBWgzjumVNG7rKb7MRSR8pOzqe76EzY
pi93VP2IfFcYBIxiI1BL677ThJihXD8tHjtErjIb+XfYqPzyY6l4xsDvdttv1Mf3
V9RWmKsA7C1gw86cqVqyIcR49NPydoT0dvq+Qh4yxLTvsBOXpdJe0UzeaHTcujcb
RLyK3pQ/XHR07jTbgzZ0Hfq0g38XB9jOJoqsGn98gr8gDEEa7Qwgg+dT1hYQIXcr
OqOZ/OpUyZUV7WPfrpjq
=T5el
-----END PGP SIGNATURE-----

--/9DWx/yDrRhgMJTb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
