Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DADA26B000C
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 20:02:41 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b7-v6so13587838qtp.14
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 17:02:41 -0700 (PDT)
Received: from o2.20qt.s2shared.sendgrid.net (o2.20qt.s2shared.sendgrid.net. [167.89.106.65])
        by mx.google.com with ESMTPS id x1-v6si4817610qtx.173.2018.07.22.17.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 22 Jul 2018 17:02:41 -0700 (PDT)
Subject: Re: [Bug 200627] New: Stutters and high kernel CPU usage from
 list_lru_count_one when cache fills memory
From: Kevin Liu <kevin@potatofrom.space>
References: <bug-200627-27@https.bugzilla.kernel.org/>
 <20180722164034.62bf461029073a21e591b8c3@linux-foundation.org>
 <5166980c-210e-2e68-974a-9115e5c72543@potatofrom.space>
Message-ID: <63e10f4d-ad8f-8d02-2f78-caf01eaa72c1@potatofrom.space>
Date: Mon, 23 Jul 2018 00:02:40 +0000 (UTC)
Mime-Version: 1.0
In-Reply-To: <5166980c-210e-2e68-974a-9115e5c72543@potatofrom.space>
Content-type: multipart/alternative; boundary="----------=_1532304160-1805-2648"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

This is a multi-part message in MIME format...

------------=_1532304160-1805-2648
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit

Sorry, not sure if the previous message registered on bugzilla due to
the pgp signature? Including it below.

On 07/22/2018 07:44 PM, Kevin Liu wrote:
>> How recently?  Were earlier kernels better behaved?
> I've seen this issue both on Linux 4.16.15 (admittedly using the -ck
> patchset) and on vanilla Linux 4.18-rc4 (which is what I'm currently using).
> 
> I'm fairly certain that it did not occur on Linux 4.14.50, which I used
> previously, but I will boot back into it to double-check and let you know.
> 

And yes, booted back into Linux 4.14.54, there appears to be no issue --
list_lru_count_one reaches 6% overhead at most:

Overhead  Shared Object                     Symbol

   5.91%  [kernel]                          [k] list_lru_count_one

   5.13%  [kernel]                          [k] nmi

   4.08%  [kernel]                          [k] read_hpet

   1.26%  zma                               [.] Zone::CheckAlarms

   1.16%  [kernel]                          [k] _raw_spin_lock

   1.07%  restic                            [.] 0x00000000002e696c

   1.06%  .perf-wrapped                     [.] hpp__sort_overhead



------------=_1532304160-1805-2648
Content-Type: text/html; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

<html><body>
<p>Sorry, not sure if the previous message registered on bugzilla due to the pgp signature? Including it below.</p>
<p>On 07/22/2018 07:44 PM, Kevin Liu wrote:</p>
<blockquote><blockquote><p>How recently?  Were earlier kernels better behaved?</p></blockquote>
<pre>I've seen this issue both on Linux 4.16.15 (admittedly using the -ck
patchset) and on vanilla Linux 4.18-rc4 (which is what I'm currently using).</pre>
<pre>I'm fairly certain that it did not occur on Linux 4.14.50, which I used
previously, but I will boot back into it to double-check and let you know.</pre></blockquote>
<p>And yes, booted back into Linux 4.14.54, there appears to be no issue &mdash; list_lru_count_one reaches 6% overhead at most:</p>
<p>Overhead  Shared Object                     Symbol</p>
<pre>5.91%  [kernel]                          [k] list_lru_count_one</pre>
<pre>5.13%  [kernel]                          [k] nmi</pre>
<pre>4.08%  [kernel]                          [k] read_hpet</pre>
<pre>1.26%  zma                               [.] Zone::CheckAlarms</pre>
<pre>1.16%  [kernel]                          [k] _raw_spin_lock</pre>
<pre>1.07%  restic                            [.] 0x00000000002e696c</pre>
<pre>1.06%  .perf-wrapped                     [.] hpp__sort_overhead</pre>

<img src="https://u7890171.ct.sendgrid.net/wf/open?upn=oDb6ny51mUB6FExYn3rQhuayDepTyfldPWjLmUXQBZExvbeD5NYD5HcMlb7DQzKmt-2BsXjMBRwrk4kOXOiGqwNUiA2b8wjbygyY7-2B-2Fx4NB8Ow5BBdj1NRBs0ENmf8dEdt0cuZxma7UlVY5-2FZO57b-2BAjxqHVT-2B0eT4na9-2BI8dBIRuhYT5t7i7yiz9BN1gez8ZWQq4PgQcPu3-2FVttvLvawV-2BLMXwtommj8yXgMNUFjEotw-3D" alt="" width="1" height="1" border="0" style="height:1px !important;width:1px !important;border-width:0 !important;margin-top:0 !important;margin-bottom:0 !important;margin-right:0 !important;margin-left:0 !important;padding-top:0 !important;padding-bottom:0 !important;padding-right:0 !important;padding-left:0 !important;"/>
</body></html>

------------=_1532304160-1805-2648--
