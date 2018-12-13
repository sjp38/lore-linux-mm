Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B70AE8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 00:02:10 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 82so715917pfs.20
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 21:02:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id az11si684154plb.386.2018.12.12.21.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 21:02:09 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <201812080950.q5whdIbk%fengguang.wu@intel.com>
 <20181209120323.lotz4v2ahywtk3hk@master>
 <f3e59ee6-9f1e-8677-e779-e3cc13151b18@intel.com>
 <20181213030832.whutggpzdy336u6y@master>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <b036dab0-6822-3a8f-b2ce-4a979506172d@intel.com>
Date: Thu, 13 Dec 2018 13:02:21 +0800
MIME-Version: 1.0
In-Reply-To: <20181213030832.whutggpzdy336u6y@master>
Content-Type: multipart/alternative;
 boundary="------------6E1A28E0FA1A291D60D3DB38"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, mgorman@techsingularity.net, akpm@linux-foundation.org

This is a multi-part message in MIME format.
--------------6E1A28E0FA1A291D60D3DB38
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit



On 12/13/2018 11:08 AM, Wei Yang wrote:
> On Thu, Dec 13, 2018 at 10:26:41AM +0800, Rong Chen wrote:
>>
>> On 12/09/2018 08:03 PM, Wei Yang wrote:
>>> On Sat, Dec 08, 2018 at 09:42:29AM +0800, kbuild test robot wrote:
>>>> Hi Wei,
>>>>
>>>> Thank you for the patch! Perhaps something to improve:
>>>>
>>>> [auto build test WARNING on linus/master]
>>>> [also build test WARNING on v4.20-rc5 next-20181207]
>>>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>>>
>>>> url:    https://github.com/0day-ci/linux/commits/Wei-Yang/mm-pageblock-make-sure-pageblock-won-t-exceed-mem_sectioin/20181207-030601
>>>> config: powerpc-allmodconfig (attached as .config)
>>>> compiler: powerpc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>>>> reproduce:
>>>>          wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>>>          chmod +x ~/bin/make.cross
>>>>          # save the attached .config to linux build tree
>>>>          GCC_VERSION=7.2.0 make.cross ARCH=powerpc
>>>>
>>>> All warnings (new ones prefixed by >>):
>>>>
>>>>     In file included from include/linux/gfp.h:6:0,
>>>>                      from include/linux/xarray.h:14,
>>>>                      from include/linux/radix-tree.h:31,
>>>>                      from include/linux/fs.h:15,
>>>>                      from include/linux/compat.h:17,
>>>>                      from arch/powerpc/kernel/asm-offsets.c:16:
>>>>>> include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>>>>      #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>>>>           ^~~~~~~~~~~~~~~
>>>> --
>>>>     In file included from include/linux/gfp.h:6:0,
>>>>                      from include/linux/mm.h:10,
>>>>                      from mm//swap.c:16:
>>>>>> include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>>>>      #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>>>>           ^~~~~~~~~~~~~~~
>>>>     In file included from include/linux/gfp.h:6:0,
>>>>                      from include/linux/mm.h:10,
>>>>                      from mm//swap.c:16:
>>>>>> include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>>>>      #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>>>>           ^~~~~~~~~~~~~~~
>>>>
>>>> vim +/pageblock_order +1088 include/linux/mmzone.h
>>>>
>>>>    1087	
>>>>> 1088	#if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>>>>    1089	#error Allocator pageblock_order exceeds SECTION_SIZE
>>>>    1090	#endif
>>>>    1091	
>>>>
>>> I took a look at the latest code, at line 1082 of the same file uses
>>> pageblock_order. And I apply this patch on top of v4.20-rc5, the build
>>> looks good to me.
>>>
>>> Confused why this introduce an compile error.
>> Hi Wei,
>>
>> we could reproduce the warnings with using make.cross.
>>
> That's interesting.
>
> Do you see this file already use pageblock_order in line 1081?
>
> Is this one report warning?
>

both questions is yes.

Best Regards,
Rong Chen



--------------6E1A28E0FA1A291D60D3DB38
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 12/13/2018 11:08 AM, Wei Yang wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20181213030832.whutggpzdy336u6y@master">
      <pre wrap="">On Thu, Dec 13, 2018 at 10:26:41AM +0800, Rong Chen wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">

On 12/09/2018 08:03 PM, Wei Yang wrote:
</pre>
        <blockquote type="cite">
          <pre wrap="">On Sat, Dec 08, 2018 at 09:42:29AM +0800, kbuild test robot wrote:
</pre>
          <blockquote type="cite">
            <pre wrap="">Hi Wei,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.20-rc5 next-20181207]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    <a class="moz-txt-link-freetext" href="https://github.com/0day-ci/linux/commits/Wei-Yang/mm-pageblock-make-sure-pageblock-won-t-exceed-mem_sectioin/20181207-030601">https://github.com/0day-ci/linux/commits/Wei-Yang/mm-pageblock-make-sure-pageblock-won-t-exceed-mem_sectioin/20181207-030601</a>
config: powerpc-allmodconfig (attached as .config)
compiler: powerpc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget <a class="moz-txt-link-freetext" href="https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross">https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross</a> -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=powerpc

All warnings (new ones prefixed by &gt;&gt;):

   In file included from include/linux/gfp.h:6:0,
                    from include/linux/xarray.h:14,
                    from include/linux/radix-tree.h:31,
                    from include/linux/fs.h:15,
                    from include/linux/compat.h:17,
                    from arch/powerpc/kernel/asm-offsets.c:16:
</pre>
            <blockquote type="cite">
              <blockquote type="cite">
                <pre wrap="">include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
</pre>
              </blockquote>
            </blockquote>
            <pre wrap="">    #if (pageblock_order + PAGE_SHIFT) &gt; SECTION_SIZE_BITS
         ^~~~~~~~~~~~~~~
--
   In file included from include/linux/gfp.h:6:0,
                    from include/linux/mm.h:10,
                    from mm//swap.c:16:
</pre>
            <blockquote type="cite">
              <blockquote type="cite">
                <pre wrap="">include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
</pre>
              </blockquote>
            </blockquote>
            <pre wrap="">    #if (pageblock_order + PAGE_SHIFT) &gt; SECTION_SIZE_BITS
         ^~~~~~~~~~~~~~~
   In file included from include/linux/gfp.h:6:0,
                    from include/linux/mm.h:10,
                    from mm//swap.c:16:
</pre>
            <blockquote type="cite">
              <blockquote type="cite">
                <pre wrap="">include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
</pre>
              </blockquote>
            </blockquote>
            <pre wrap="">    #if (pageblock_order + PAGE_SHIFT) &gt; SECTION_SIZE_BITS
         ^~~~~~~~~~~~~~~

vim +/pageblock_order +1088 include/linux/mmzone.h

  1087	
</pre>
            <blockquote type="cite">
              <pre wrap="">1088	#if (pageblock_order + PAGE_SHIFT) &gt; SECTION_SIZE_BITS
</pre>
            </blockquote>
            <pre wrap="">  1089	#error Allocator pageblock_order exceeds SECTION_SIZE
  1090	#endif
  1091	

</pre>
          </blockquote>
          <pre wrap="">I took a look at the latest code, at line 1082 of the same file uses
pageblock_order. And I apply this patch on top of v4.20-rc5, the build
looks good to me.

Confused why this introduce an compile error.
</pre>
        </blockquote>
        <pre wrap="">
Hi Wei,

we could reproduce the warnings with using make.cross.

</pre>
      </blockquote>
      <pre wrap="">
That's interesting.

Do you see this file already use pageblock_order in line 1081?

Is this one report warning?

</pre>
    </blockquote>
    <br>
    <span id="w_228" class="high-light">both </span><span id="w_229"
      class="">questions </span><span id="w_230" class="">is </span><span
      id="w_231" class="high-light">yes</span><span id="w_232" class="">.<br>
      <br>
      Best Regards,<br>
      Rong Chen<br>
      <br>
    </span>
    <blockquote type="cite"
      cite="mid:20181213030832.whutggpzdy336u6y@master">
      <pre wrap="">
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------6E1A28E0FA1A291D60D3DB38--
