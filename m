Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id ADE4E6B0007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:28:09 -0500 (EST)
Message-ID: <50F85ED5.3010003@jp.fujitsu.com>
Date: Thu, 17 Jan 2013 15:28:05 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com> <50F440F5.3030006@zytor.com> <20130114143456.3962f3bd.akpm@linux-foundation.org> <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com> <20130114144601.1c40dc7e.akpm@linux-foundation.org> <50F647E8.509@jp.fujitsu.com> <20130116132953.6159b673.akpm@linux-foundation.org> <50F72F17.9030805@zytor.com> <50F78750.8070403@jp.fujitsu.com> <50F79422.6090405@zytor.com> <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C986D98@ORSMSX108.amr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com
Cc: hpa@zytor.com, isimatu.yasuaki@jp.fujitsu.com, akpm@linux-foundation.org, tangchen@cn.fujitsu.com, jiang.liu@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 1/17/2013 11:30 AM, Luck, Tony wrote:
>> 2. If the user *does* care which nodes are movable, then the user needs 
>> to be able to specify that *in a way that makes sense to the user*. 
>> This may mean involving the DMI information as well as SRAT in order to 
>> get "silk screen" type information out.
> 
> One reason they might care would be which I/O devices are connected
> to each node.  DMI might be a good way to get an invariant name for the
> node, but they might also want to specify in terms of what they actually
> want. E.g. "eth0 and eth4 are a redundant bonded pair of NICs - don't
> mark both these nodes as removable".  Though this is almost certainly not
> a job for kernel options, but for some user configuration tool that would
> spit out the DMI names.

I agree DMI parsing should be done in userland if we really need DMI parsing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
