Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1308AC4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:33:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA25C21907
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:33:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA25C21907
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63B066B0320; Wed, 18 Sep 2019 21:33:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EC0A6B0321; Wed, 18 Sep 2019 21:33:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D9B76B0322; Wed, 18 Sep 2019 21:33:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 2C85B6B0320
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:33:28 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D3E4C180AD808
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:33:27 +0000 (UTC)
X-FDA: 75949947654.27.scarf23_7562beaf3c936
X-HE-Tag: scarf23_7562beaf3c936
X-Filterd-Recvd-Size: 3418
Received: from wangsu.com (unknown [123.103.51.227])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:33:26 +0000 (UTC)
Received: from localhost.localdomain (unknown [218.85.123.226])
	by app2 (Coremail) with SMTP id 4zNnewDHpwDA2oJdbAABAA--.14S2;
	Thu, 19 Sep 2019 09:32:49 +0800 (CST)
Subject: Re: [PATCH] [RESEND] vmscan.c: add a sysctl entry for controlling
 memory reclaim IO congestion_wait length
To: Michal Hocko <mhocko@kernel.org>
Cc: corbet@lwn.net, mcgrof@kernel.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, keescook@chromium.org,
 mchehab+samsung@kernel.org, mgorman@techsingularity.net, vbabka@suse.cz,
 ktkhai@virtuozzo.com, hannes@cmpxchg.org, willy@infradead.org,
 kbuild test robot <lkp@intel.com>
References: <20190918095159.27098-1-linf@wangsu.com>
 <20190918122738.GE12770@dhcp22.suse.cz>
From: Lin Feng <linf@wangsu.com>
Message-ID: <c5f278da-ec68-3206-d91b-d1ca7c97bb8c@wangsu.com>
Date: Thu, 19 Sep 2019 09:32:48 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190918122738.GE12770@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CM-TRANSID:4zNnewDHpwDA2oJdbAABAA--.14S2
X-Coremail-Antispam: 1UD129KBjvdXoWruF17try7Kw4xCF1kXF4DXFb_yoWfJwbE9F
	18Krnxuws5KF4DWFsrJrnxCrykKw4rtr1kWrW8JrnxGa4rJF1rAa95Ww1kWa1kt3y8WrZr
	XrySkryDXw129jkaLaAFLSUrUUUUUb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUIcSsGvfJTRUUUbVxYjsxI4VWkCwAYFVCjjxCrM7CY07I20VC2zVCF04k26cxKx2IY
	s7xG6rWj6s0DM28lY4IEw2IIxxk0rwA2F7IY1VAKz4vEj48ve4kI8wA2z4x0Y4vE2Ix0cI
	8IcVAFwI0_tr0E3s1l84ACjcxK6xIIjxv20xvEc7CjxVAFwI0_GcCE3s1l84ACjcxK6I8E
	87Iv67AKxVW0oVCq3wA2z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1le2I262IYc4CY6c
	8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E74AGY7Cv6cx26r48McIj
	6xkF7I0En7xvr7AKxVWUJVW8JwAm72CE4IkC6x0Yz7v_Jr0_Gr1lF7xvr2IY64vIr41lFI
	xGxcIEc7CjxVA2Y2ka0xkIwI1lc7I2V7IY0VAS07AlzVAYIcxG8wCY02Avz4vE14v_KwCF
	04k20xvY0x0EwIxGrwCF04k20xvE74AGY7Cv6cx26r48MxC20s026xCaFVCjc4AY6r1j6r
	4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CEb7AF
	67AKxVWUtVW8ZwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14v26r1j6r1xMIIF0xvE2I
	x0cI8IcVCY1x0267AKxVW8JVWxJwCI42IY6xAIw20EY4v20xvaj40_WFyUJVCq3wCI42IY
	6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r4j6r4UJbIYCTnIWIevJa
	73UjIFyTuYvjxU1qXdUUUUU
X-CM-SenderInfo: holqwq5zdqw23xof0z/
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/18/19 20:27, Michal Hocko wrote:
> Please do not post a new version with a minor compile fixes until there
> is a general agreement on the approach. Willy had comments which really
> need to be resolved first. 

Sorry, but thanks for pointing out.

> 
> Also does this
> [...]
>> Reported-by: kbuild test robot<lkp@intel.com>
> really hold? Because it suggests that the problem has been spotted by
> the kbuild bot which is kinda unexpected... I suspect you have just
> added that for the minor compilation issue that you have fixed since the
> last version.

Yes, I do know the issue is not reported by the robot, but
just followed the kbuild robot tip, this Reported-by suggested by kbuild robot
seems a little misleading, I'm not sure if it has other meanings.
'If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>'


