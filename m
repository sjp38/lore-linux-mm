Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 585EB6B0294
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 09:31:25 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id r55so8577235otc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:31:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si6404720oti.243.2017.11.22.06.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 06:31:24 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
 <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
 <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
 <20171122124551.tjxt7td5fmfqifnc@dhcp22.suse.cz>
 <201711222206.JGF73535.OFFQSLOJFtHMVO@I-love.SAKURA.ne.jp>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <b04f6093-3b22-e57f-a276-bfaaf3b0ba1e@redhat.com>
Date: Wed, 22 Nov 2017 15:31:14 +0100
MIME-Version: 1.0
In-Reply-To: <201711222206.JGF73535.OFFQSLOJFtHMVO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com
Cc: akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, david@fromorbit.com, viro@zeniv.linux.org.uk, jack@suse.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On 22/11/2017 14:06, Tetsuo Handa wrote:
>> I am not sure we want to overcomplicate the code too much. Most
>> architectures do not have that many numa nodes to care. If we really
>> need to care maybe we should rethink and get rid of the per numa
>> deferred count altogether.
> the amount of changes needed for checking for an error will exceed the amount of
> changes needed for making register_shrinker() not to return an error.
> Do we want to overcomplicate register_shrinker() callers?

For KVM it's not a big deal, fixing kvm_mmu_module_init to check the
return value is trivial.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
