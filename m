Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 54CEE6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 04:26:23 -0500 (EST)
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
From: li guang <lig.fnst@cn.fujitsu.com>
In-Reply-To: <50F902F6.5010605@cn.fujitsu.com>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
	 <50F440F5.3030006@zytor.com>
	 <20130114143456.3962f3bd.akpm@linux-foundation.org>
	 <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
	 <20130114144601.1c40dc7e.akpm@linux-foundation.org>
	 <50F647E8.509@jp.fujitsu.com>
	 <20130116132953.6159b673.akpm@linux-foundation.org>
	 <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com>
	 <50F79422.6090405@zytor.com>
	 <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>
	 <50F85ED5.3010003@jp.fujitsu.com> <50F8E63F.5040401@jp.fujitsu.com>
	 <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com>
	 <50F8FBE9.6040501@jp.fujitsu.com>  <50F902F6.5010605@cn.fujitsu.com>
Date: Fri, 18 Jan 2013 17:23:51 +0800
Message-ID: <1358501031.22331.10.camel@liguang.fnst.cn.fujitsu.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tony.luck@intel.com, akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=E5=9C=A8 2013-01-18=E4=BA=94=E7=9A=84 16:08 +0800=EF=BC=8CTang Chen=E5=86=
=99=E9=81=93=EF=BC=9A
> On 01/18/2013 03:38 PM, Yasuaki Ishimatsu wrote:
> > 2013/01/18 15:25, H. Peter Anvin wrote:
> >> We already do DMI parsing in the kernel...
> >
> > Thank you for giving the infomation.
> >
> > Is your mention /sys/firmware/dmi/entries?
> >
> > If so, my box does not have memory information.
> > My box has only type 0, 1, 2, 3, 4, 7, 8, 9, 38, 127 in DMI.
> > At least, my box cannot use the information...
> >
> > If users use the boot parameter for investigating firmware bugs
> > or debugging, users cannot use DMI information on like my box.
>=20
> And seeing from Documentation/ABI/testing/sysfs-firmware-dmi,
>=20
> 	The kernel itself does not rely on the majority of the
> 	information in these tables being correct.  It equally
> 	cannot ensure that the data as exported to userland is
> 	without error either.
>=20
> So when users are doing debug, they should not rely on this info.

kernel absolutely should not care much about SMBIOS(DMI info),
AFAIK, every BIOS vendor did not fill accurate info in SMBIOS,
mostly only on demand when OEMs required SMBIOS to report some
specific info.
furthermore, SMBIOS is so old and benifit nobody(in my personal
opinion), so maybe let's forget it.

>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
regards!
li guang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
