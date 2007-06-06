Date: Wed, 6 Jun 2007 13:43:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <20070606133432.2f3cb26a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706061336450.12665@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
 <20070606100817.7af24b74.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
 <20070606131121.a8f7be78.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com>
 <20070606133432.2f3cb26a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2007, Andrew Morton wrote:

> I tried to build gcc-3.3.3 the other day.  Would you believe that gcc-4.1.0
> fails to compile gcc-3.3.3?

Yes I tried building a gcc compiler for a special config a while back. 
After a few days I came to the firm conclusion that its not worth the 
time. Fortunately I found a group of guys that do it all for me and I get 
daily updates of their work.

clameter@schroedinger:~$ apt-cache search gcc
cpp - The GNU C preprocessor (cpp)
cpp-2.95 - The GNU C preprocessor
cpp-2.95-doc - Documentation for the GNU C preprocessor (cpp)
cpp-3.3 - The GNU C preprocessor
cpp-3.4 - The GNU C preprocessor
cpp-4.1 - The GNU C preprocessor
cpp-4.2 - The GNU C preprocessor
cpphs - Simplified cpp-a-like preprocessor for Haskell
emdebian-tools - emdebian crossbuilding tool set
g++-2.95 - The GNU C++ compiler
g++-3.4 - The GNU C++ compiler
g77 - The GNU Fortran 77 compiler
g77-2.95 - The GNU Fortran 77 compiler
g77-2.95-doc - Documentation for the GNU Fortran compiler (g77)
g77-3.4 - The GNU Fortran 77 compiler
gcc - The GNU C compiler
gcc-2.95 - The GNU C compiler
gcc-2.95-doc - Documentation for the GNU compilers (gcc, gobjc, g++)
gcc-3.3 - The GNU C compiler
gcc-3.3-base - The GNU Compiler Collection (base package)
gcc-3.4 - The GNU C compiler
gcc-3.4-base - The GNU Compiler Collection (base package)
gcc-4.1 - The GNU C compiler
gcc-4.1-base - The GNU Compiler Collection (base package)
gcc-4.1-locales - The GNU C compiler (native language support files)
gcc-4.1-source - Source of the GNU Compiler Collection
gcc-4.2 - The GNU C compiler
gcc-4.2-base - The GNU Compiler Collection (base package)
gcc-4.2-doc - Documentation for the GNU compilers (gcc, gobjc, g++)
gcc-4.2-locales - The GNU C compiler (native language support files)
gcc-4.2-multilib - The GNU C compiler (multilib files)
gcc-4.2-source - Source of the GNU Compiler Collection
gcc-avr - The GNU C compiler (cross compiler for avr)
gcc-m68hc1x - GNU C compiler for the Motorola 68HC11/12 processors
gcc272 - The GNU C compiler.
gcc272-docs - Documentation for the gcc compiler (gcc272).
gccxml - XML output extension to GCC
gcj - The GNU Java compiler
gcj-4.1 - The GNU compiler for Java(TM)
gcj-4.1-base - The GNU Compiler Collection (gcj base package)
gfortran - The GNU Fortran 95 compiler
gfortran-4.1 - The GNU Fortran 95 compiler
gfortran-4.2 - The GNU Fortran 95 compiler
gfortran-4.2-multilib - The GNU Fortran 95 compiler (multilib files)
ggcov - Graphical tool for displaying gcov test coverage data
gnat-4.1 - The GNU Ada compiler
gnat-4.1-base - The GNU Compiler Collection (gnat base package)
gobjc - The GNU Objective-C compiler
gobjc++ - The GNU Objective-C++ compiler
gobjc++-4.1 - The GNU Objective-C++ compiler
gobjc++-4.2 - The GNU Objective-C++ compiler
gobjc++-4.2-multilib - The GNU Objective-C++ compiler (multilib files)
gobjc-2.95 - The GNU Objective-C compiler
gobjc-4.1 - The GNU Objective-C compiler
gobjc-4.2 - The GNU Objective-C compiler
gobjc-4.2-multilib - The GNU Objective-C compiler (multilib files)
gpc - The GNU Pascal compiler
gpc-2.1-3.4 - The GNU Pascal compiler
gpc-2.1-3.4-doc - Documentation for the GNU Pascal compiler (gpc)
gpc-2.95 - The GNU Pascal compiler
gpc-2.95-doc - Documentation for the GNU Pascal compiler (gpc)
cpp-3.3-arm-linux-gnu - The GNU C preprocessor
cpp-3.3-ia64-linux-gnu - The GNU C preprocessor
cpp-3.3-m68k-linux-gnu - The GNU C preprocessor
cpp-3.3-mips-linux-gnu - The GNU C preprocessor
cpp-3.3-mipsel-linux-gnu - The GNU C preprocessor
cpp-3.3-powerpc-linux-gnu - The GNU C preprocessor
cpp-3.3-sparc-linux-gnu - The GNU C preprocessor
cpp-3.4-alpha-linux-gnu - The GNU C preprocessor
cpp-3.4-arm-linux-gnu - The GNU C preprocessor
cpp-3.4-ia64-linux-gnu - The GNU C preprocessor
cpp-3.4-m68k-linux-gnu - The GNU C preprocessor
cpp-3.4-mips-linux-gnu - The GNU C preprocessor
cpp-3.4-mipsel-linux-gnu - The GNU C preprocessor
cpp-3.4-powerpc-linux-gnu - The GNU C preprocessor
cpp-3.4-sparc-linux-gnu - The GNU C preprocessor
cpp-4.0-arm-linux-gnu - The GNU C preprocessor
cpp-4.0-ia64-linux-gnu - The GNU C preprocessor
cpp-4.0-mips-linux-gnu - The GNU C preprocessor
cpp-4.0-mipsel-linux-gnu - The GNU C preprocessor
cpp-4.0-powerpc-linux-gnu - The GNU C preprocessor
cpp-4.0-sparc-linux-gnu - The GNU C preprocessor
cpp-4.1-alpha-linux-gnu - The GNU C preprocessor
cpp-4.1-arm-linux-gnu - The GNU C preprocessor
cpp-4.1-ia64-linux-gnu - The GNU C preprocessor
cpp-4.1-m68k-linux-gnu - The GNU C preprocessor
cpp-4.1-mips-linux-gnu - The GNU C preprocessor
cpp-4.1-mipsel-linux-gnu - The GNU C preprocessor
cpp-4.1-powerpc-linux-gnu - The GNU C preprocessor
cpp-4.1-s390-linux-gnu - The GNU C preprocessor
cpp-4.1-sparc-linux-gnu - The GNU C preprocessor
g++-3.4-alpha-linux-gnu - The GNU C++ compiler
g++-3.4-arm-linux-gnu - The GNU C++ compiler
g++-3.4-ia64-linux-gnu - The GNU C++ compiler
g++-3.4-m68k-linux-gnu - The GNU C++ compiler
g++-3.4-mips-linux-gnu - The GNU C++ compiler
g++-3.4-mipsel-linux-gnu - The GNU C++ compiler
g++-3.4-powerpc-linux-gnu - The GNU C++ compiler
g++-3.4-sparc-linux-gnu - The GNU C++ compiler
gcc-3.3-alpha-linux-gnu - The GNU C compiler
gcc-3.3-arm-linux-gnu - The GNU C compiler
gcc-3.3-ia64-linux-gnu - The GNU C compiler
gcc-3.3-m68k-linux-gnu - The GNU C compiler
gcc-3.3-mips-linux-gnu - The GNU C compiler
gcc-3.3-mipsel-linux-gnu - The GNU C compiler
gcc-3.3-powerpc-linux-gnu - The GNU C compiler
gcc-3.3-sparc-linux-gnu - The GNU C compiler
gcc-3.4-alpha-linux-gnu - The GNU C compiler
gcc-3.4-arm-linux-gnu - The GNU C compiler
gcc-3.4-ia64-linux-gnu - The GNU C compiler
gcc-3.4-m68k-linux-gnu - The GNU C compiler
gcc-3.4-mips-linux-gnu - The GNU C compiler
gcc-3.4-mipsel-linux-gnu - The GNU C compiler
gcc-3.4-powerpc-linux-gnu - The GNU C compiler
gcc-3.4-sparc-linux-gnu - The GNU C compiler
gcc-4.0-arm-linux-gnu - The GNU C compiler
gcc-4.0-arm-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.0-ia64-linux-gnu - The GNU C compiler
gcc-4.0-ia64-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.0-m68k-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.0-mips-linux-gnu - The GNU C compiler
gcc-4.0-mips-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.0-mipsel-linux-gnu - The GNU C compiler
gcc-4.0-mipsel-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.0-powerpc-linux-gnu - The GNU C compiler
gcc-4.0-powerpc-linux-gnu-base - The GNU Compiler Collection (base 
package)
gcc-4.0-sparc-linux-gnu - The GNU C compiler
gcc-4.0-sparc-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-alpha-linux-gnu - The GNU C compiler
gcc-4.1-alpha-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-arm-linux-gnu - The GNU C compiler
gcc-4.1-arm-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-ia64-linux-gnu - The GNU C compiler
gcc-4.1-ia64-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-m68k-linux-gnu - The GNU C compiler
gcc-4.1-m68k-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-mips-linux-gnu - The GNU C compiler
gcc-4.1-mips-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-mipsel-linux-gnu - The GNU C compiler
gcc-4.1-mipsel-linux-gnu-base - The GNU Compiler Collection (base package)
gcc-4.1-powerpc-linux-gnu - The GNU C compiler
gcc-4.1-powerpc-linux-gnu-base - The GNU Compiler Collection (base 
package)
gcc-4.1-s390-linux-gnu - The GNU C compiler
gcc-4.1-sparc-linux-gnu - The GNU C compiler
gcc-4.1-sparc-linux-gnu-base - The GNU Compiler Collection (base package)
lib64gcc1-powerpc-cross - GCC support library (64bit)
lib64gcc1-s390-cross - GCC support library (64bit)
lib64gcc1-sparc-cross - GCC support library (64bit)
libgcc1-alpha-cross - GCC support library
libgcc1-arm-cross - GCC support library
libgcc1-ia64-cross - GCC support library
libgcc1-m68k-cross - GCC support library
libgcc1-mips-cross - GCC support library
libgcc1-mipsel-cross - GCC support library
libgcc1-powerpc-cross - GCC support library
libgcc1-s390-cross - GCC support library
libgcc1-sparc-cross - GCC support library
libgcc2-m68k-cross - GCC support library
libgcc4-hppa-cross - GCC support library (for cross-compiling)
cpp-4.0 - The GNU C preprocessor
libgcj6-common - Java runtime library for use with gcj (jar files)
gcc-4.0 - The GNU C compiler
libgcj6 - Java runtime library for use with gcj
gcc-4.0-base - The GNU Compiler Collection (base package)
gcj-4.0-base - The GNU Compiler Collection (gcj base package)
toolchain-source - The GNU binutils and gcc source code


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
