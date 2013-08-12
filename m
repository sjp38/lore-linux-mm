Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 4D7A86B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 02:33:33 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3027895pdj.1
        for <linux-mm@kvack.org>; Sun, 11 Aug 2013 23:33:32 -0700 (PDT)
Message-ID: <520881AD.1020800@gmail.com>
Date: Mon, 12 Aug 2013 14:33:17 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130809163220.GU20515@mtj.dyndns.org>
In-Reply-To: <20130809163220.GU20515@mtj.dyndns.org>
Content-Type: multipart/alternative;
 boundary="------------080605040401010200060007"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This is a multi-part message in MIME format.
--------------080605040401010200060007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 08/10/2013 12:32 AM, Tejun Heo wrote:
> Hello,
>
> On Thu, Aug 08, 2013 at 06:16:12PM +0800, Tang Chen wrote:
>> In previous parts' patches, we have obtained SRAT earlier enough, right after
>> memblock is ready. So this patch-set does the following things:
> Can you please set up a git branch with all patches?
Hi tj,

Please refer to the following tree:
https://github.com/imtangchen/linux movablenode-boot-option

It contains all 5 parts patches.

Thanks.

>
>


--------------080605040401010200060007
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    On 08/10/2013 12:32 AM, Tejun Heo wrote:
    <blockquote cite="mid:20130809163220.GU20515@mtj.dyndns.org"
      type="cite">
      <pre wrap="">Hello,

On Thu, Aug 08, 2013 at 06:16:12PM +0800, Tang Chen wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">In previous parts' patches, we have obtained SRAT earlier enough, right after
memblock is ready. So this patch-set does the following things:
</pre>
      </blockquote>
      <pre wrap="">
Can you please set up a git branch with all patches?</pre>
    </blockquote>
    Hi tj,<br>
    <br>
    Please refer to the following tree:<br>
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <a href="https://github.com/imtangchen/linux">https://github.com/imtangchen/linux</a>
    movablenode-boot-option<br>
    <br>
    It contains all 5 parts patches.<br>
    <br>
    Thanks.<br>
    <br>
    <blockquote cite="mid:20130809163220.GU20515@mtj.dyndns.org"
      type="cite">
      <pre wrap="">


</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------080605040401010200060007--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
