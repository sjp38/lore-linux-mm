Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6947D6B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 04:55:21 -0400 (EDT)
Received: by pawu10 with SMTP id u10so3448983paw.1
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 01:55:21 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id lv12si621498pab.240.2015.08.04.01.55.18
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 01:55:19 -0700 (PDT)
Message-ID: <55C07D9C.8070505@cn.fujitsu.com>
Date: Tue, 4 Aug 2015 16:53:48 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86, gfp: Cache best near node for memory allocation.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>, 	<1436261425-29881-2-git-send-email-tangchen@cn.fujitsu.com>, 	<20150715214802.GL15934@mtj.duckdns.org>, 	<55C03332.2030808@cn.fujitsu.com> <201508041626380745999@inspur.com>
In-Reply-To: <201508041626380745999@inspur.com>
Content-Type: multipart/alternative;
	boundary="------------060205060606090707070204"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "gongzhaogang@inspur.com" <gongzhaogang@inspur.com>, "tj@kernel.org" <tj@kernel.org>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "hpa@zytor.com" <hpa@zytor.com>, tangchen@cn.fujitsu.com, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "qiaonuohan@cn.fujitsu.com" <qiaonuohan@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--------------060205060606090707070204
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit


On 08/04/2015 04:26 PM, gongzhaogang@inspur.com wrote:
> Sorry,I am new.
> >But,
> >1) in cpu_up(), it will try to online a node, and it doesn't check if
> >the node has memory.
> >2) in try_offline_node(), it offlines CPUs first, and then the memory.
> >This behavior looks a little wired, or let's say it is ambiguous. It
> >seems that a NUMA node
> >consists of CPUs and memory. So if the CPUs are online, the node should
> >be online.
> I suggested you to try the patch offered by Liu Jiang.
>
> https://lkml.org/lkml/2014/9/11/1087

Well, I think Liu Jiang meant this patch set. :)

https://lkml.org/lkml/2014/7/11/75

>
> I have tried ,It is OK.
>
> >Unfortunately, since I don't have a machine a with memory-less node, I
> >cannot reproduce
> >the problem right now.
>
> If  not hurried  , I can test your patches in our environment on weekends.

Thanks. But this version of my patch set is obviously problematic.
It will be very nice of you if you can help to test the next version.
But maybe in a few days.

Thanks. :)

>
> ------------------------------------------------------------------------
> gongzhaogang@inspur.com
>
>     *From:* Tang Chen <mailto:tangchen@cn.fujitsu.com>
>     *Date:* 2015-08-04 11:36
>     *To:* Tejun Heo <mailto:tj@kernel.org>
>     *CC:* mingo@redhat.com <mailto:mingo@redhat.com>;
>     akpm@linux-foundation.org <mailto:akpm@linux-foundation.org>;
>     rjw@rjwysocki.net <mailto:rjw@rjwysocki.net>; hpa@zytor.com
>     <mailto:hpa@zytor.com>; laijs@cn.fujitsu.com
>     <mailto:laijs@cn.fujitsu.com>; yasu.isimatu@gmail.com
>     <mailto:yasu.isimatu@gmail.com>; isimatu.yasuaki@jp.fujitsu.com
>     <mailto:isimatu.yasuaki@jp.fujitsu.com>;
>     kamezawa.hiroyu@jp.fujitsu.com
>     <mailto:kamezawa.hiroyu@jp.fujitsu.com>; izumi.taku@jp.fujitsu.com
>     <mailto:izumi.taku@jp.fujitsu.com>; gongzhaogang@inspur.com
>     <mailto:gongzhaogang@inspur.com>; qiaonuohan@cn.fujitsu.com
>     <mailto:qiaonuohan@cn.fujitsu.com>; x86@kernel.org
>     <mailto:x86@kernel.org>; linux-acpi@vger.kernel.org
>     <mailto:linux-acpi@vger.kernel.org>; linux-kernel@vger.kernel.org
>     <mailto:linux-kernel@vger.kernel.org>; linux-mm@kvack.org
>     <mailto:linux-mm@kvack.org>; tangchen@cn.fujitsu.com
>     <mailto:tangchen@cn.fujitsu.com>
>     *Subject:* Re: [PATCH 1/5] x86, gfp: Cache best near node for
>     memory allocation.
>     Hi TJ,
>     Sorry for the late reply.
>     On 07/16/2015 05:48 AM, Tejun Heo wrote:
>     > ......
>     > so in initialization pharse makes no sense any more. The best
>     near online
>     > node for each cpu should be cached somewhere.
>     > I'm not really following.  Is this because the now offline node can
>     > later come online and we'd have to break the constant mapping
>     > invariant if we update the mapping later?  If so, it'd be nice to
>     > spell that out.
>     Yes. Will document this in the next version.
>     >> ......
>     >>
>     >> +int get_near_online_node(int node)
>     >> +{
>     >> + return per_cpu(x86_cpu_to_near_online_node,
>     >> + cpumask_first(&node_to_cpuid_mask_map[node]));
>     >> +}
>     >> +EXPORT_SYMBOL(get_near_online_node);
>     > Umm... this function is sitting on a fairly hot path and scanning a
>     > cpumask each time.  Why not just build a numa node -> numa node
>     array?
>     Indeed. Will avoid to scan a cpumask.
>     > ......
>     >
>     >>
>     >>   static inline struct page *alloc_pages_exact_node(int nid,
>     gfp_t gfp_mask,
>     >>   unsigned int order)
>     >>   {
>     >> - VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>     >> + VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
>     >> +
>     >> +#if IS_ENABLED(CONFIG_X86) && IS_ENABLED(CONFIG_NUMA)
>     >> + if (!node_online(nid))
>     >> + nid = get_near_online_node(nid);
>     >> +#endif
>     >>
>     >>   return __alloc_pages(gfp_mask, order, node_zonelist(nid,
>     gfp_mask));
>     >>   }
>     > Ditto.  Also, what's the synchronization rules for NUMA node
>     > on/offlining.  If you end up updating the mapping later, how would
>     > that be synchronized against the above usages?
>     I think the near online node map should be updated when node
>     online/offline
>     happens. But about this, I think the current numa code has a
>     little problem.
>     As you know, firmware info binds a set of CPUs and memory to a
>     node. But
>     at boot time, if the node has no memory (a memory-less node) , it
>     won't
>     be online.
>     But the CPUs on that node is available, and bound to the near
>     online node.
>     (Here, I mean numa_set_node(cpu, node).)
>     Why does the kernel do this ? I think it is used to ensure that we
>     can
>     allocate memory
>     successfully by calling functions like alloc_pages_node() and
>     alloc_pages_exact_node().
>     By these two fuctions, any CPU should be bound to a node who has
>     memory
>     so that
>     memory allocation can be successful.
>     That means, for a memory-less node at boot time, CPUs on the node is
>     online,
>     but the node is not online.
>     That also means, "the node is online" equals to "the node has
>     memory".
>     Actually, there
>     are a lot of code in the kernel is using this rule.
>     But,
>     1) in cpu_up(), it will try to online a node, and it doesn't check if
>     the node has memory.
>     2) in try_offline_node(), it offlines CPUs first, and then the memory.
>     This behavior looks a little wired, or let's say it is ambiguous. It
>     seems that a NUMA node
>     consists of CPUs and memory. So if the CPUs are online, the node
>     should
>     be online.
>     And also,
>     The main purpose of this patch-set is to make the cpuid <-> nodeid
>     mapping persistent.
>     After this patch-set, alloc_pages_node() and alloc_pages_exact_node()
>     won't depend on
>     cpuid <-> nodeid mapping any more. So the node should be online if
>     the
>     CPUs on it are
>     online. Otherwise, we cannot setup interfaces of CPUs under /sys.
>     Unfortunately, since I don't have a machine a with memory-less
>     node, I
>     cannot reproduce
>     the problem right now.
>     How do you think the node online behavior should be changed ?
>     Thanks.
>


--------------060205060606090707070204
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <br>
    <div class="moz-cite-prefix">On 08/04/2015 04:26 PM,
      <a class="moz-txt-link-abbreviated" href="mailto:gongzhaogang@inspur.com">gongzhaogang@inspur.com</a> wrote:<br>
    </div>
    <blockquote cite="mid:201508041626380745999@inspur.com" type="cite">
      <meta http-equiv="Content-Type" content="text/html;
        charset=ISO-8859-1">
      <style>body { line-height: 1.5; }blockquote { margin-top: 0px; margin-bottom: 0px; margin-left: 0.5em; }body { font-size: 10.5pt; font-family: ????; color: rgb(0, 0, 0); line-height: 1.5; }</style>
      <div><span></span>Sorry,I am new.</div>
      <div>
        <div>&gt;But,</div>
        <div>&gt;1) in cpu_up(), it will try to online a node, and it
          doesn't check if</div>
        <div>&gt;the node has memory.</div>
        <div>&gt;2) in try_offline_node(), it offlines CPUs first, and
          then the memory.</div>
        <div>&nbsp;</div>
        <div>&gt;This behavior looks a little wired, or let's say it is
          ambiguous. It</div>
        <div>&gt;seems that a NUMA node</div>
        <div>&gt;consists of CPUs and memory. So if the CPUs are online,
          the node should</div>
        <div>&gt;be online.</div>
      </div>
      <div>I suggested you to try the patch offered by Liu Jiang.</div>
      <div><br>
      </div>
      <div><span style="background-color: rgba(0, 0, 0, 0); font-size:
          10.5pt; line-height: 1.5;"><a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2014/9/11/1087">https://lkml.org/lkml/2014/9/11/1087</a></span>
        <br>
      </div>
    </blockquote>
    <br>
    Well, I think Liu Jiang meant this patch set. :)<br>
    <br>
    <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2014/7/11/75">https://lkml.org/lkml/2014/7/11/75</a><br>
    <br>
    <blockquote cite="mid:201508041626380745999@inspur.com" type="cite"><br>
      <div>I have tried ,It is OK.</div>
      <div><br>
      </div>
      <div>
        <div>&gt;Unfortunately, since I don't have a machine a with
          memory-less node, I</div>
        <div>&gt;cannot reproduce</div>
        <div>&gt;the problem right now.</div>
      </div>
      <div><br>
      </div>
      <div>If &nbsp;not hurried &nbsp;, I can test your patches in our environment
        on weekends.</div>
    </blockquote>
    <br>
    Thanks. But this version of my patch set is obviously problematic. <br>
    It will be very nice of you if you can help to test the next
    version.<br>
    But maybe in a few days.<br>
    <br>
    Thanks. :)<br>
    <br>
    <blockquote cite="mid:201508041626380745999@inspur.com" type="cite">
      <div><br>
      </div>
      <hr style="width: 210px; height: 1px;" color="#b5c4df"
        align="left" size="1">
      <div><span>
          <div style="MARGIN: 10px; FONT-FAMILY: verdana; FONT-SIZE:
            10pt">
            <div><a class="moz-txt-link-abbreviated" href="mailto:gongzhaogang@inspur.com">gongzhaogang@inspur.com</a></div>
          </div>
        </span></div>
      <blockquote style="margin-top: 0px; margin-bottom: 0px;
        margin-left: 0.5em;">
        <div>&nbsp;</div>
        <div style="border:none;border-top:solid #B5C4DF
          1.0pt;padding:3.0pt 0cm 0cm 0cm">
          <div style="PADDING-RIGHT: 8px; PADDING-LEFT: 8px; FONT-SIZE:
            12px;FONT-FAMILY:tahoma;COLOR:#000000; BACKGROUND: #efefef;
            PADDING-BOTTOM: 8px; PADDING-TOP: 8px">
            <div><b>From:</b>&nbsp;<a moz-do-not-send="true"
                href="mailto:tangchen@cn.fujitsu.com">Tang Chen</a></div>
            <div><b>Date:</b>&nbsp;2015-08-04&nbsp;11:36</div>
            <div><b>To:</b>&nbsp;<a moz-do-not-send="true"
                href="mailto:tj@kernel.org">Tejun Heo</a></div>
            <div><b>CC:</b>&nbsp;<a moz-do-not-send="true"
                href="mailto:mingo@redhat.com">mingo@redhat.com</a>; <a
                moz-do-not-send="true"
                href="mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>;
              <a moz-do-not-send="true" href="mailto:rjw@rjwysocki.net">rjw@rjwysocki.net</a>;
              <a moz-do-not-send="true" href="mailto:hpa@zytor.com">hpa@zytor.com</a>;
              <a moz-do-not-send="true"
                href="mailto:laijs@cn.fujitsu.com">laijs@cn.fujitsu.com</a>;
              <a moz-do-not-send="true"
                href="mailto:yasu.isimatu@gmail.com">yasu.isimatu@gmail.com</a>;
              <a moz-do-not-send="true"
                href="mailto:isimatu.yasuaki@jp.fujitsu.com">isimatu.yasuaki@jp.fujitsu.com</a>;
              <a moz-do-not-send="true"
                href="mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>;
              <a moz-do-not-send="true"
                href="mailto:izumi.taku@jp.fujitsu.com">izumi.taku@jp.fujitsu.com</a>;
              <a moz-do-not-send="true"
                href="mailto:gongzhaogang@inspur.com">gongzhaogang@inspur.com</a>;
              <a moz-do-not-send="true"
                href="mailto:qiaonuohan@cn.fujitsu.com">qiaonuohan@cn.fujitsu.com</a>;
              <a moz-do-not-send="true" href="mailto:x86@kernel.org">x86@kernel.org</a>;
              <a moz-do-not-send="true"
                href="mailto:linux-acpi@vger.kernel.org">linux-acpi@vger.kernel.org</a>;
              <a moz-do-not-send="true"
                href="mailto:linux-kernel@vger.kernel.org">linux-kernel@vger.kernel.org</a>;
              <a moz-do-not-send="true" href="mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>;
              <a moz-do-not-send="true"
                href="mailto:tangchen@cn.fujitsu.com">tangchen@cn.fujitsu.com</a></div>
            <div><b>Subject:</b>&nbsp;Re: [PATCH 1/5] x86, gfp: Cache best
              near node for memory allocation.</div>
          </div>
        </div>
        <div>
          <div>Hi TJ,</div>
          <div>&nbsp;</div>
          <div>Sorry for the late reply.</div>
          <div>&nbsp;</div>
          <div>On 07/16/2015 05:48 AM, Tejun Heo wrote:</div>
          <div>&gt; ......</div>
          <div>&gt; so in initialization pharse makes no sense any more.
            The best near online</div>
          <div>&gt; node for each cpu should be cached somewhere.</div>
          <div>&gt; I'm not really following.&nbsp; Is this because the now
            offline node can</div>
          <div>&gt; later come online and we'd have to break the
            constant mapping</div>
          <div>&gt; invariant if we update the mapping later?&nbsp; If so,
            it'd be nice to</div>
          <div>&gt; spell that out.</div>
          <div>&nbsp;</div>
          <div>Yes. Will document this in the next version.</div>
          <div>&nbsp;</div>
          <div>&gt;&gt; ......</div>
          <div>&gt;&gt;&nbsp;&nbsp; </div>
          <div>&gt;&gt; +int get_near_online_node(int node)</div>
          <div>&gt;&gt; +{</div>
          <div>&gt;&gt; + return per_cpu(x86_cpu_to_near_online_node,</div>
          <div>&gt;&gt; + &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            cpumask_first(&amp;node_to_cpuid_mask_map[node]));</div>
          <div>&gt;&gt; +}</div>
          <div>&gt;&gt; +EXPORT_SYMBOL(get_near_online_node);</div>
          <div>&gt; Umm... this function is sitting on a fairly hot path
            and scanning a</div>
          <div>&gt; cpumask each time.&nbsp; Why not just build a numa node
            -&gt; numa node array?</div>
          <div>&nbsp;</div>
          <div>Indeed. Will avoid to scan a cpumask.</div>
          <div>&nbsp;</div>
          <div>&gt; ......</div>
          <div>&gt;</div>
          <div>&gt;&gt;&nbsp;&nbsp; </div>
          <div>&gt;&gt;&nbsp;&nbsp; static inline struct page
            *alloc_pages_exact_node(int nid, gfp_t gfp_mask,</div>
          <div>&gt;&gt;&nbsp;&nbsp; unsigned int order)</div>
          <div>&gt;&gt;&nbsp;&nbsp; {</div>
          <div>&gt;&gt; - VM_BUG_ON(nid &lt; 0 || nid &gt;= MAX_NUMNODES
            || !node_online(nid));</div>
          <div>&gt;&gt; + VM_BUG_ON(nid &lt; 0 || nid &gt;=
            MAX_NUMNODES);</div>
          <div>&gt;&gt; +</div>
          <div>&gt;&gt; +#if IS_ENABLED(CONFIG_X86) &amp;&amp;
            IS_ENABLED(CONFIG_NUMA)</div>
          <div>&gt;&gt; + if (!node_online(nid))</div>
          <div>&gt;&gt; + nid = get_near_online_node(nid);</div>
          <div>&gt;&gt; +#endif</div>
          <div>&gt;&gt;&nbsp;&nbsp; </div>
          <div>&gt;&gt;&nbsp;&nbsp; return __alloc_pages(gfp_mask, order,
            node_zonelist(nid, gfp_mask));</div>
          <div>&gt;&gt;&nbsp;&nbsp; }</div>
          <div>&gt; Ditto.&nbsp; Also, what's the synchronization rules for
            NUMA node</div>
          <div>&gt; on/offlining.&nbsp; If you end up updating the mapping
            later, how would</div>
          <div>&gt; that be synchronized against the above usages?</div>
          <div>&nbsp;</div>
          <div>I think the near online node map should be updated when
            node online/offline</div>
          <div>happens. But about this, I think the current numa code
            has a little problem.</div>
          <div>&nbsp;</div>
          <div>As you know, firmware info binds a set of CPUs and memory
            to a node. But</div>
          <div>at boot time, if the node has no memory (a memory-less
            node) , it won't </div>
          <div>be online.</div>
          <div>But the CPUs on that node is available, and bound to the
            near online node.</div>
          <div>(Here, I mean numa_set_node(cpu, node).)</div>
          <div>&nbsp;</div>
          <div>Why does the kernel do this ? I think it is used to
            ensure that we can </div>
          <div>allocate memory</div>
          <div>successfully by calling functions like alloc_pages_node()
            and </div>
          <div>alloc_pages_exact_node().</div>
          <div>By these two fuctions, any CPU should be bound to a node
            who has memory </div>
          <div>so that</div>
          <div>memory allocation can be successful.</div>
          <div>&nbsp;</div>
          <div>That means, for a memory-less node at boot time, CPUs on
            the node is </div>
          <div>online,</div>
          <div>but the node is not online.</div>
          <div>&nbsp;</div>
          <div>That also means, "the node is online" equals to "the node
            has memory". </div>
          <div>Actually, there</div>
          <div>are a lot of code in the kernel is using this rule.</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>But,</div>
          <div>1) in cpu_up(), it will try to online a node, and it
            doesn't check if </div>
          <div>the node has memory.</div>
          <div>2) in try_offline_node(), it offlines CPUs first, and
            then the memory.</div>
          <div>&nbsp;</div>
          <div>This behavior looks a little wired, or let's say it is
            ambiguous. It </div>
          <div>seems that a NUMA node</div>
          <div>consists of CPUs and memory. So if the CPUs are online,
            the node should </div>
          <div>be online.</div>
          <div>&nbsp;</div>
          <div>And also,</div>
          <div>The main purpose of this patch-set is to make the cpuid
            &lt;-&gt; nodeid </div>
          <div>mapping persistent.</div>
          <div>After this patch-set, alloc_pages_node() and
            alloc_pages_exact_node() </div>
          <div>won't depend on</div>
          <div>cpuid &lt;-&gt; nodeid mapping any more. So the node
            should be online if the </div>
          <div>CPUs on it are</div>
          <div>online. Otherwise, we cannot setup interfaces of CPUs
            under /sys.</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>Unfortunately, since I don't have a machine a with
            memory-less node, I </div>
          <div>cannot reproduce</div>
          <div>the problem right now.</div>
          <div>&nbsp;</div>
          <div>How do you think the node online behavior should be
            changed ?</div>
          <div>&nbsp;</div>
          <div>Thanks.</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
          <div>&nbsp;</div>
        </div>
      </blockquote>
    </blockquote>
    <br>
  </body>
</html>

--------------060205060606090707070204--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
