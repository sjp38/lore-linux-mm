Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5E07B6B0038
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 00:34:57 -0400 (EDT)
Received: by oicf142 with SMTP id f142so82480889oic.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:34:57 -0700 (PDT)
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com. [209.85.214.179])
        by mx.google.com with ESMTPS id om9si2289523oeb.76.2015.03.27.21.34.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 21:34:56 -0700 (PDT)
Received: by obvd1 with SMTP id d1so21773380obv.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:34:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150327141922.GC5481@dhcp22.suse.cz>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150327141922.GC5481@dhcp22.suse.cz>
Date: Sat, 28 Mar 2015 10:04:56 +0530
Message-ID: <CAKohpo=3x8hPe9AEJWNgRvD1iT+npbX+-k0t3EZEDyHUsv4AqQ@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

On 27 March 2015 at 19:49, Michal Hocko <mhocko@suse.cz> wrote:

> Wouldn't something like I was suggesting few months back
> (http://article.gmane.org/gmane.linux.kernel.mm/127569) solve this
> problem as well? Scheduler should be idle aware, no? I mean it shouldn't
> wake up an idle CPU if the task might run on another one.

Probably yes. Lets see what others have to say about it..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
