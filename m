Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 2A8A46B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 01:25:49 -0500 (EST)
In-Reply-To: <50F8E63F.5040401@jp.fujitsu.com>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com> <50F79422.6090405@zytor.com> <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com> <50F85ED5.3010003@jp.fujitsu.com> <50F8E63F.5040401@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 17 Jan 2013 22:25:20 -0800
Message-ID: <818a2b0a-f471-413f-9231-6167eb2d9607@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tony.luck@intel.com
Cc: akpm@linux-foundation.org, tangchen@cn.fujitsu.com, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We already do DMI parsing in the kernel...

Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

>2013/01/18 5:28, KOSAKI Motohiro wrote:
>> On 1/17/2013 11:30 AM, Luck, Tony wrote:
>>>> 2. If the user *does* care which nodes are movable, then the user
>needs
>>>> to be able to specify that *in a way that makes sense to the user*.
>>>> This may mean involving the DMI information as well as SRAT in
>order to
>>>> get "silk screen" type information out.
>>>
>>> One reason they might care would be which I/O devices are connected
>>> to each node.  DMI might be a good way to get an invariant name for
>the
>>> node, but they might also want to specify in terms of what they
>actually
>>> want. E.g. "eth0 and eth4 are a redundant bonded pair of NICs -
>don't
>>> mark both these nodes as removable".  Though this is almost
>certainly not
>>> a job for kernel options, but for some user configuration tool that
>would
>>> spit out the DMI names.
>>
>> I agree DMI parsing should be done in userland if we really need DMI
>parsing.
>>
>
>If users use the boot parameter for bugs or debugging,  users need
>a method which sets in detail range of movable memory. So specifying
>node number is not enough because whole memory becomes movable memory.
>
>For this, we are discussing other ways, memory range and DMI
>information.
>By using DMI information, users may get an invariant name. But is it
>really user friendly interface? I don't think so.
>
>You will think using memory range is not user friendly interface too.
>But I think that using memory range is friendlier than using DMI
>information since we can get easily memory range. So from developper
>side, using memory range is good.
>
>Of course, using SRAT information is necessary solution. So we are
>developing it now.
>
>Thanks,
>Yasuaki Ishimatsu

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
