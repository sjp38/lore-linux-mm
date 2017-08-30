Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3106B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:27:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t82so2317103wmd.10
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 06:27:44 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id c20si5756381ede.45.2017.08.30.06.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 06:27:42 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id 187so1482631wmn.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 06:27:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170830095735.GB31503@amd>
References: <20170816231458.2299-1-labbott@redhat.com> <20170816231458.2299-3-labbott@redhat.com>
 <20170817033148.ownsmbdzk2vhupme@thunk.org> <20170830095735.GB31503@amd>
From: Nick Kralevich <nnk@google.com>
Date: Wed, 30 Aug 2017 06:27:40 -0700
Message-ID: <CAFJ0LnEduPL4RJLyJv-pZdrncfwS0r1mQ_26tKASDB4nf-Xjjw@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCHv3 2/2] extract early boot entropy
 from the passed cmdline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, Daniel Micay <danielmicay@gmail.com>, kernel-hardening@lists.openwall.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 2:57 AM, Pavel Machek <pavel@ucw.cz> wrote:
> The command line is visible to unpriviledged userspace (/proc/cmdline,
> dmesg). Is that a problem?

These files are not exposed to untrusted processes on Android.

-- 
Nick Kralevich | Android Security | nnk@google.com | 650.214.4037

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
