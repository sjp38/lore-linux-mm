Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 097AC6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 21:54:35 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id hh10so60734550pac.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:54:35 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ye8si380249pab.169.2016.07.19.18.54.33
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 18:54:34 -0700 (PDT)
Subject: Re: [PATCH v8 1/7] x86, memhp, numa: Online memory-less nodes at boot
 time.
References: <1468913288-16605-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1468913288-16605-2-git-send-email-douly.fnst@cn.fujitsu.com>
 <20160719185017.GM3078@mtj.duckdns.org>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <dcce26e9-bd9f-e9db-b1c7-6a18271395f2@cn.fujitsu.com>
Date: Wed, 20 Jul 2016 09:52:56 +0800
MIME-Version: 1.0
In-Reply-To: <20160719185017.GM3078@mtj.duckdns.org>
Content-Type: multipart/alternative;
	boundary="------------E4C35AA4269377E76DF27B3E"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

--------------E4C35AA4269377E76DF27B3E
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit



a?? 2016a1'07ae??20ae?JPY 02:50, Tejun Heo a??e??:
> Hello,
>
> On Tue, Jul 19, 2016 at 03:28:02PM +0800, Dou Liyang wrote:
>> In this series of patches, we are going to construct cpu <-> node mapping
>> for all possible cpus at boot time, which is a 1-1 mapping. It means the
> 1-1 mapping means that each cpu is mapped to its own private node
> which isn't the case.  Just call it a persistent mapping?

Yes, each cpu is just in a persistent node.
However, the opposite is not true.

I will modify it.


>
>> cpu will be mapped to the node it belongs to, and will never be changed.
>> If a node has only cpus but no memory, the cpus on it will be mapped to
>> a memory-less node. And the memory-less node should be onlined.
>>
>> This patch allocate pgdats for all memory-less nodes and online them at
>> boot time. Then build zonelists for these nodes. As a result, when cpus
>> on these memory-less nodes try to allocate memory from local node, it
>> will automatically fall back to the proper zones in the zonelists.
> Yeah, I think this is an a lot better approach for memory-less nodes.
>
>> Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

Thanks,

Dou





--------------E4C35AA4269377E76DF27B3E
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">a?? 2016a1'07ae??20ae?JPY 02:50, Tejun Heo a??e??:<br>
    </div>
    <blockquote cite="mid:20160719185017.GM3078@mtj.duckdns.org"
      type="cite">
      <pre wrap="">Hello,

On Tue, Jul 19, 2016 at 03:28:02PM +0800, Dou Liyang wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">In this series of patches, we are going to construct cpu &lt;-&gt; node mapping
for all possible cpus at boot time, which is a 1-1 mapping. It means the
</pre>
      </blockquote>
      <pre wrap="">
1-1 mapping means that each cpu is mapped to its own private node
which isn't the case.  Just call it a persistent mapping?</pre>
    </blockquote>
    <pre>
Yes, each cpu is just in a persistent node.
<span class="" id="w_11" high-light-id="w_0,w_11">However</span><span class="" id="w_12" high-light-id="w_1,w_12">, </span><span id="w_13" high-light-id="">the </span><span id="w_14" high-light-id="w_2,w_14" class="high-light">opposite </span><span class="" id="w_15" high-light-id="w_3,w_15">is </span><span class="" id="w_16" high-light-id="w_4,w_16">not </span><span id="w_17" high-light-id="w_7,w_17" class="high-light">true</span><span class="" id="w_20" high-light-id="w_9,w_20"></span><span class="" id="w_21" high-light-id="w_10,w_21">. </span>

I will modify it.</pre>
    <br>
    <blockquote cite="mid:20160719185017.GM3078@mtj.duckdns.org"
      type="cite">
      <pre wrap="">

</pre>
      <blockquote type="cite">
        <pre wrap="">cpu will be mapped to the node it belongs to, and will never be changed.
If a node has only cpus but no memory, the cpus on it will be mapped to
a memory-less node. And the memory-less node should be onlined.

This patch allocate pgdats for all memory-less nodes and online them at
boot time. Then build zonelists for these nodes. As a result, when cpus
on these memory-less nodes try to allocate memory from local node, it
will automatically fall back to the proper zones in the zonelists.
</pre>
      </blockquote>
      <pre wrap="">
Yeah, I think this is an a lot better approach for memory-less nodes.

</pre>
      <blockquote type="cite">
        <pre wrap="">Signed-off-by: Zhu Guihua <a class="moz-txt-link-rfc2396E" href="mailto:zhugh.fnst@cn.fujitsu.com">&lt;zhugh.fnst@cn.fujitsu.com&gt;</a>
</pre>
      </blockquote>
    </blockquote>
    <pre>
Thanks,

Dou
</pre>
    <br>
  </body>
</html>

--------------E4C35AA4269377E76DF27B3E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
