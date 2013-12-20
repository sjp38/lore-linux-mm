Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAD36B0081
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 09:32:45 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id j5so5910605qaq.7
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 06:32:44 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id r6si5970004qaj.159.2013.12.20.06.32.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 06:32:43 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id g10so2590416pdj.31
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 06:32:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA6-i6pDqDemeQ+s4EorOx39qmNAtAfVYfg0Z2wtTEu-S7mY=A@mail.gmail.com>
References: <cover.1387193771.git.vdavydov@parallels.com>
	<abff42910c131a9c94a7518de59b283ee0a2dcd1.1387193771.git.vdavydov@parallels.com>
	<20131220092659.0ed23cf5@redhat.com>
	<CAA6-i6pDqDemeQ+s4EorOx39qmNAtAfVYfg0Z2wtTEu-S7mY=A@mail.gmail.com>
Date: Fri, 20 Dec 2013 18:32:41 +0400
Message-ID: <CAA6-i6rqCm44yJjf0dy=L+rYGEH=WUoNzX4+qh5poGgSsA=W-Q@mail.gmail.com>
Subject: Re: [PATCH v14 16/18] vmpressure: in-kernel notifications
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, dchinner@redhat.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

One correction:

>>  int vmpressure_register_kernel_event(struct cgroup_subsys_state *css,
>> -                                     void (*fn)(void))
>> +                                    void (*fn)(void *data, int level), void *data)
>>  {
>> -       struct vmpressure *vmpr = css_to_vmpressure(css);
>> +       struct vmpressure *vmpr;
>>         struct vmpressure_event *ev;
>>
>> +       vmpr = css ? css_to_vmpressure(css) : memcg_to_vmpressure(NULL);
>> +

This looks like it could be improved. Better not to have that memcg
specific thing
here.

Other than that it makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
