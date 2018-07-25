Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00E426B02A2
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:29:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y17-v6so3027409eds.22
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:29:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e29-v6si465905eda.181.2018.07.25.05.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 05:29:45 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:29:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some
 machines
Message-ID: <20180725122944.GH28386@dhcp22.suse.cz>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz>
 <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
 <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
 <CAOm-9aqYLExQZUvfk9ucCoSPoaA67D6ncEDR2+UZBMLhv4-r_A@mail.gmail.com>
 <CADF2uSrL-o9QJ9aXM7+wbX+c6g8Pe2jwp1RFL5qvSBj27MSkHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSrL-o9QJ9aXM7+wbX+c6g8Pe2jwp1RFL5qvSBj27MSkHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org

On Tue 24-07-18 12:50:27, Marinko Catovic wrote:
> I hope this is kinda related, so we can work together on pinpointing this,
> that issue is not going away
> for me and causes lots of headache slowing down my entire business.

It think your problem is not really related. I still didn't get to your
collected data but this issue is more related to the laziness of the
cgroup objects tear down.

-- 
Michal Hocko
SUSE Labs
