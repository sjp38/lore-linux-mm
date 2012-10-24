Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 00FBE6B0062
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:14:31 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so1633713ied.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 13:14:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121012145114.GZ29125@suse.de>
References: <20121012145114.GZ29125@suse.de>
Date: Wed, 24 Oct 2012 17:14:31 -0300
Message-ID: <CALF0-+UBq8kgC-uUkuk_akoyBgvkytgn0v+2uBTDLZcFCPeHrQ@mail.gmail.com>
Subject: Re: MMTests 0.06
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: multipart/mixed; boundary=f46d044787d302cf6d04ccd3bc51
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--f46d044787d302cf6d04ccd3bc51
Content-Type: text/plain; charset=ISO-8859-1

Hi,

On Fri, Oct 12, 2012 at 11:51 AM, Mel Gorman <mgorman@suse.de> wrote:
> MMTests 0.06 is a configurable test suite that runs a number of common
> workloads of interest to MM developers. There are multiple additions
> all but in many respects the most useful will be automatic package
> installation. The package names are based on openSUSE but it's easy to
> create mappings in bin/install-depends where the package names differ. The
> very basics of monitoring NUMA efficiency is there as well and the autonuma
> benchmark has a test. The stats it reports for NUMA need significant
> improvement but for the most part that should be straight forward.
>
> Changelog since v0.05
> o Automatically install packages (need name mappings for other distros)
> o Add benchmark for autonumabench
> o Add support for benchmarking NAS with MPI
> o Add pgbench for autonumabench (may need a bit more work)
> o Upgrade postgres version to 9.2.1
> o Upgrade kernel verion used for kernbench to 3.0 for newer toolchains
> o Alter mailserver config to finish in a reasonable time
> o Add monitor for perf sched
> o Add moinitor that gathers ftrace information with trace-cmd
> o Add preliminary monitors for NUMA stats (very basic)
> o Specify ftrace events to monitor from config file
> o Remove the bulk of whats left of VMRegress
> o Convert shellpacks to a template format to auto-generate boilerplate code
> o Collect lock_stat information if enabled
> o Run multiple iterations of aim9
> o Add basic regression tests for Cross Memory Attach
> o Copy with preempt being enabled in highalloc stres tests
> o Have largedd cope with a missing large file to work with
> o Add a monitor-only mode to just capture logs
> o Report receive-side throughput in netperf for results
>
> At LSF/MM at some point a request was made that a series of tests
> be identified that were of interest to MM developers and that could be
> used for testing the Linux memory management subsystem. There is renewed
> interest in some sort of general testing framework during discussions for
> Kernel Summit 2012 so here is what I use.
>
> http://www.csn.ul.ie/~mel/projects/mmtests/
> http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.06-mmtests-0.01.tar.gz
>
> There are a number of stock configurations stored in configs/.  For example
> config-global-dhp__pagealloc-performance runs a number of tests that
> may be able to identify performance regressions or gains in the page
> allocator. Similarly there network and scheduler configs. There are also
> more complex options. config-global-dhp__parallelio-memcachetest will run
> memcachetest in the foreground while doing IO of different sizes in the
> background to measure how much unrelated IO affects the throughput of an
> in-memory database.
>
> This release is also a little rough and the extraction scripts could
> have been tidier but they were mostly written in an airport and for the
> most part they work as advertised. I'll fix bugs as according as they are
> brought to my attention.
>
> The stats reporting still needs work because while some tests know how
> to make a better estimate of mean by filtering outliers it is not being
> handled consistently and the methodology needs work. I know filtering
> statistics like this is a major flaw in the methodology but the decision
> was made in this case in the interest of the benchmarks with unstable
> results completing in a reasonable time.
>

FWIW, I found a minor problem with sudo and yum incantation when trying this.

I'm attaching a patch.

Hope it helps,

    Ezequiel

--f46d044787d302cf6d04ccd3bc51
Content-Type: application/octet-stream; name="yum-fix-install-option.patch"
Content-Disposition: attachment; filename="yum-fix-install-option.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h8ovsfl60

ZGlmZiAtTmF1ciBtbXRlc3RzLTAuMDYtbW10ZXN0cy0wLjAxL2Jpbi9pbnN0YWxsLWRlcGVuZHMg
bW10ZXN0cy0wLjA2LW1tdGVzdHMtMC4wMS1taW5lL2Jpbi9pbnN0YWxsLWRlcGVuZHMKLS0tIG1t
dGVzdHMtMC4wNi1tbXRlc3RzLTAuMDEvYmluL2luc3RhbGwtZGVwZW5kcwkyMDEyLTEwLTEyIDEx
OjI4OjQyLjAwMDAwMDAwMCAtMDMwMAorKysgbW10ZXN0cy0wLjA2LW1tdGVzdHMtMC4wMS1taW5l
L2Jpbi9pbnN0YWxsLWRlcGVuZHMJMjAxMi0xMC0yNCAxNjo1OTo0MS4wMjk0MTcxOTMgLTAzMDAK
QEAgLTExLDcgKzExLDcgQEAKIAlteSAkYmluYXJ5ID0gJF9bMF07CiAKIAlvcGVuKEJPREdFLCAi
d2hpY2ggJGJpbmFyeSAyPi9kZXYvbnVsbCB8IikgfHwgZGllKCJGYWlsZWQgdG8gb3BlbiBwaXBl
IHRvIHdoaWNoIik7Ci0JbXkgJGxpbmUgPSA8Qk9ER0U+OworCWNob21wKG15ICRsaW5lID0gPEJP
REdFPik7CiAJY2xvc2UoQk9ER0UpOwogCXJldHVybiAkbGluZTsKIH0KQEAgLTI2LDcgKzI2LDcg
QEAKIG15ICVwYWNrYWdlX2JpbiA9ICgKIAkic3VzZSIgICA9PiAienlwcGVyIGluc3RhbGwgLXki
LAogCSJkZWJpYW4iID0+ICJhcHQtZ2V0IGluc3RhbGwgLXkgLS1mb3JjZS15ZXMiLAotCSJyZWRo
YXQiID0+ICJ5dW0gaW5zdGFsbCAtaSIsCisJInJlZGhhdCIgPT4gInl1bSBpbnN0YWxsIC15IiwK
ICk7CiAKIGlmICgkRU5WeyJBU1NVTUVfUEFDS0FHRV9JTlNUQUxMRUQifSBlcSAieWVzIikgewo=
--f46d044787d302cf6d04ccd3bc51--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
