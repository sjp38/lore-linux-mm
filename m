Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C39F6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 02:53:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j8so422370pfh.13
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 23:53:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30-v6si973703pla.444.2018.03.19.23.53.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 23:53:57 -0700 (PDT)
Date: Tue, 20 Mar 2018 07:53:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: KVM hang after OOM
Message-ID: <20180320065339.GA23100@dhcp22.suse.cz>
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
 <b9ef3b5f-37c2-649a-2c90-8fbbf2bd3bed@i-love.sakura.ne.jp>
 <178719aa-b669-c443-bf87-5728b71557c0@i-love.sakura.ne.jp>
 <CABXGCsNecgRN7mn4OxZY2rqa2N4kVBw3f0s6XEvLob4uy3LOug@mail.gmail.com>
 <201803171213.BFF21361.OOSFVFHLJQOtFM@I-love.SAKURA.ne.jp>
 <CABXGCsN8mN7bGNDx9Tb2sewuXWp6DbcyKpMFv0UzGATAMELxqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsN8mN7bGNDx9Tb2sewuXWp6DbcyKpMFv0UzGATAMELxqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, kvm@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon 19-03-18 21:23:12, Mikhail Gavrilov wrote:
> Good news 4.16.0-rc6 with proposed patch not hangs after OOM anymore!
> Of course I would be more happy If was possible protect GUI from
> memory pressing and save responsiveness from lags when system begin

It seems it is "Web Content" that is eating a lot of memory. Maybe it
would help to put this process into a dedicated memory cgroup with some
reasonable limit and thus reduce the pressure to the system as whole.

[...]
> using swap actively.
> But I'm already satisfied with proposed patch.
> 
> I am attached dmesg when I triggering OOM three times. And every time
> after it system survived.
> I think this patch should be merged in mainline.

Could you be more specific what is _this_ patch, please?
-- 
Michal Hocko
SUSE Labs
