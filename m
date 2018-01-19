Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0C8E6B026D
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:02:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x16so1392053pfe.20
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 02:02:35 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0043.outbound.protection.outlook.com. [104.47.33.43])
        by mx.google.com with ESMTPS id t134si8090406pgc.168.2018.01.19.02.02.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 02:02:34 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz>
 <DM5PR1201MB01216B72BEF121DD25AB7247FDEF0@DM5PR1201MB0121.namprd12.prod.outlook.com>
 <20180119082517.GM6584@dhcp22.suse.cz>
From: roger <honghe@amd.com>
Message-ID: <59079b24-ce47-1ddd-6b22-7b5f97408fad@amd.com>
Date: Fri, 19 Jan 2018 18:02:12 +0800
MIME-Version: 1.0
In-Reply-To: <20180119082517.GM6584@dhcp22.suse.cz>
Content-Type: multipart/alternative;
	boundary="------------895D7552FEADF0C62940E1E0"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "He, Roger" <Hongbo.He@amd.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "Koenig, Christian" <Christian.Koenig@amd.com>

--------------895D7552FEADF0C62940E1E0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit



On 2018a1'01ae??19ae?JPY 16:25, Michal Hocko wrote:
> [removed the broken quoting - please try to use an email client which
> doesn't mess up the qouted text]
>
> On Fri 19-01-18 06:01:26, He, Roger wrote:
> [...]
>> I think you are misunderstanding here.
>> Actually for now, the memory in TTM Pools already has mm_shrink which is implemented in ttm_pool_mm_shrink_init.
>> And here the memory we want to make it contribute to OOM badness is not in TTM Pools.
>> Because when TTM buffer allocation success, the memory already is removed from TTM Pools.
>
>     I have no idea what TTM buffers are. But this smells like something
>     rather specific to the particular subsytem. And my main objection here
>     is that struct file is not a proper vehicle to carry such an
>     information. So whatever the TTM subsystem does it should contribute to
>     generic counters rather than abuse fd because it happens to use it to
>     communicate with userspace.
>
 A A  got it. thanks.
>


--------------895D7552FEADF0C62940E1E0
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <br>
    <div class="moz-cite-prefix">On 2018a1'01ae??19ae?JPY 16:25, Michal Hocko
      wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20180119082517.GM6584@dhcp22.suse.cz">
      <pre wrap="">[removed the broken quoting - please try to use an email client which
doesn't mess up the qouted text]

On Fri 19-01-18 06:01:26, He, Roger wrote:
[...]
</pre>
      <blockquote type="cite">
        <pre wrap="">I think you are misunderstanding here.
Actually for now, the memory in TTM Pools already has mm_shrink which is implemented in ttm_pool_mm_shrink_init.
And here the memory we want to make it contribute to OOM badness is not in TTM Pools.
Because when TTM buffer allocation success, the memory already is removed from TTM Pools.  
</pre>
      </blockquote>
      <blockquote>
        <pre wrap="">
I have no idea what TTM buffers are. But this smells like something
rather specific to the particular subsytem. And my main objection here
is that struct file is not a proper vehicle to carry such an
information. So whatever the TTM subsystem does it should contribute to
generic counters rather than abuse fd because it happens to use it to
communicate with userspace.</pre>
      </blockquote>
    </blockquote>
    A A  got it. thanks.<br>
    <blockquote type="cite"
      cite="mid:20180119082517.GM6584@dhcp22.suse.cz">
      <blockquote>
        <pre wrap="">
</pre>
      </blockquote>
    </blockquote>
    <br>
  </body>
</html>

--------------895D7552FEADF0C62940E1E0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
