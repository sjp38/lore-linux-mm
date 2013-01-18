Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 5F8C86B0008
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 03:09:06 -0500 (EST)
Message-ID: <50F902F6.5010605@cn.fujitsu.com>
Date: Fri, 18 Jan 2013 16:08:22 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com> <50F79422.6090405@zytor.com> <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com> <50F85ED5.3010003@jp.fujitsu.com> <50F8E63F.5040401@jp.fujitsu.com> <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com> <50F8FBE9.6040501@jp.fujitsu.com>
In-Reply-To: <50F8FBE9.6040501@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tony.luck@intel.com, akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/18/2013 03:38 PM, Yasuaki Ishimatsu wrote:
> 2013/01/18 15:25, H. Peter Anvin wrote:
>> We already do DMI parsing in the kernel...
>
> Thank you for giving the infomation.
>
> Is your mention /sys/firmware/dmi/entries?
>
> If so, my box does not have memory information.
> My box has only type 0, 1, 2, 3, 4, 7, 8, 9, 38, 127 in DMI.
> At least, my box cannot use the information...
>
> If users use the boot parameter for investigating firmware bugs
> or debugging, users cannot use DMI information on like my box.

And seeing from Documentation/ABI/testing/sysfs-firmware-dmi,

	The kernel itself does not rely on the majority of the
	information in these tables being correct.  It equally
	cannot ensure that the data as exported to userland is
	without error either.

So when users are doing debug, they should not rely on this info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
