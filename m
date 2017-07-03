Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7796B0292
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 11:37:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id j85so19876370wmj.2
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 08:37:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m184si10858718wmm.190.2017.07.03.08.37.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 08:37:19 -0700 (PDT)
Date: Mon, 3 Jul 2017 17:37:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?5Zue5aSN77yaW1BBVENI?= =?utf-8?Q?=5D?= mm: vmpressure:
 simplify pressure ratio calculation
Message-ID: <20170703153716.GC11848@dhcp22.suse.cz>
References: <b7riv0v73isdtxyi4coi6g7b.1499072995215@email.android.com>
 <00146e00-d941-4311-8494-3e4220b04103.zbestahu@aliyun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <00146e00-d941-4311-8494-3e4220b04103.zbestahu@aliyun.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zbestahu <zbestahu@aliyun.com>
Cc: akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Yue Hu <huyue2@coolpad.com>, Anton Vorontsov <anton.vorontsov@linaro.org>

Please do not top post.

On Mon 03-07-17 22:19:02, zbestahu wrote:
> Yes, the original code using scale should be about rounding to
> integer. I am trying to improve the calculation because i think the
> rounding seems to be useless, we can calculate pressure directly just
> like original code of "pressure = pressure * 100 / scale", no
> floating number issue.From the view of disassembly, the patch is also
> better than original.  If original code using scale is more powerful
> than the patch, please ignore the submit.

Make sure you describe all that in the changelog because your original
patch description wasn't all that clear about your intention.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
